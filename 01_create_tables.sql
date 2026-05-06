USE library_management_system;

-- 1. Drop tables in reverse dependency order
DROP TABLE IF EXISTS Reservations;
DROP TABLE IF EXISTS Fines;
DROP TABLE IF EXISTS Borrowing;
DROP TABLE IF EXISTS Book_Authors;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Librarians;
DROP TABLE IF EXISTS Members;

-- 2. Create tables in dependency order

CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    department VARCHAR(100),
    registration_date DATE DEFAULT (CURDATE())
);

CREATE TABLE Librarians (
    librarian_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20)
);

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL
);

CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    isbn VARCHAR(30) UNIQUE,
    category_id INT,
    publisher VARCHAR(100),
    publish_year INT,
    total_copies INT NOT NULL,
    available_copies INT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT,
    CONSTRAINT chk_copies_non_negative CHECK (available_copies >= 0),
    CONSTRAINT chk_copies_max CHECK (available_copies <= total_copies)
);

CREATE TABLE Book_Authors (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE
);

CREATE TABLE Borrowing (
    borrow_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    librarian_id INT,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) DEFAULT 'Borrowed',
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (librarian_id) REFERENCES Librarians(librarian_id) ON DELETE RESTRICT,
    CONSTRAINT chk_borrow_status CHECK (status IN ('Borrowed', 'Returned'))
);

CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    borrow_id INT,
    fine_amount DECIMAL(10,2) NOT NULL,
    paid_status VARCHAR(20) DEFAULT 'Unpaid',
    FOREIGN KEY (borrow_id) REFERENCES Borrowing(borrow_id) ON DELETE RESTRICT,
    CONSTRAINT chk_fine_amount CHECK (fine_amount > 0)
);

CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT,
    book_id INT,
    reservation_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT,
    CONSTRAINT chk_reservation_status CHECK (status IN ('Pending', 'Completed', 'Cancelled'))
);

-- 3. Create indexes for frequently queried columns

CREATE INDEX idx_borrowing_status ON Borrowing(status);
CREATE INDEX idx_borrowing_due_date ON Borrowing(due_date);
CREATE INDEX idx_fines_paid_status ON Fines(paid_status);
CREATE INDEX idx_books_category ON Books(category_id);
