USE library_management_system;

-- 1. Insert Members
INSERT INTO Members (full_name, email, phone, department, registration_date) VALUES
('Ahmed Ali', 'ahmed@student.edu.eg', '01012345678', 'Computer Science', '2023-09-01'),
('Fatma Hassan', 'fatma@student.edu.eg', '01123456789', 'Mathematics', '2023-09-05'),
('Mahmoud Tarek', 'mahmoud@student.edu.eg', '01234567890', 'History', '2023-09-10'),
('Nour Emad', 'nour@student.edu.eg', '01512345678', 'Literature', '2023-09-15'),
('Youssef Omar', 'youssef@student.edu.eg', '01098765432', 'Engineering', '2023-09-20');

-- 2. Insert Librarians
INSERT INTO Librarians (full_name, email, phone) VALUES
('Mostafa Kamal', 'mostafa.k@library.eg', '01198765432'),
('Salma Magdy', 'salma.m@library.eg', '01298765432');

-- 3. Insert Categories
INSERT INTO Categories (category_name) VALUES
('Computer Science'),
('Mathematics'),
('History'),
('Literature'),
('Engineering');

-- 4. Insert Authors
INSERT INTO Authors (author_name) VALUES
('Ahmed Khaled Tawfik'),
('Naguib Mahfouz'),
('Taha Hussein'),
('Robert C. Martin'),
('Thomas Cormen'),
('Charles Leiserson'),
('Ronald Rivest'),
('Alan Turing');

-- 5. Insert Books
-- Includes 2 books with available_copies = 0 (Book 3, Book 9)
-- Includes books that will never be borrowed (Book 2, Book 4, Book 6, Book 7, Book 8)
INSERT INTO Books (title, isbn, category_id, publisher, publish_year, total_copies, available_copies) VALUES
('Introduction to Algorithms', '978-0262033848', 1, 'MIT Press', 2009, 10, 9),
('Clean Code', '978-0132350884', 1, 'Prentice Hall', 2008, 5, 5),
('Utopia', '978-0140449105', 4, 'Penguin Classics', 2003, 3, 0),
('Children of the Alley', '978-0385264731', 4, 'Doubleday', 1959, 4, 4),
('The Days', '978-9774162440', 4, 'AUC Press', 1997, 2, 1),
('Discrete Mathematics', '978-0131593183', 2, 'Pearson', 2008, 6, 6),
('Calculus I', '978-0538497817', 2, 'Cengage', 2011, 8, 8),
('History of Modern Egypt', '978-0521437885', 3, 'Cambridge Press', 1991, 3, 3),
('Engineering Mechanics', '978-0133918922', 5, 'Pearson', 2015, 2, 0),
('Data Structures', '978-0132576277', 1, 'Pearson', 2011, 5, 3);

-- 6. Insert Book_Authors
-- Solves many-to-many relationship
INSERT INTO Book_Authors (book_id, author_id) VALUES
(1, 5), (1, 6), (1, 7),  -- Book with multiple authors
(2, 4),
(3, 1),
(4, 2),
(5, 3),
(6, 8),
(7, 8),                  -- Author with multiple books (Author 8)
(8, 1),                  -- Author with multiple books (Author 1)
(9, 1),
(10, 4);                 -- Author with multiple books (Author 4)

-- 7. Insert Borrowing
-- Includes 3 overdue records (due_date < CURDATE() and status = 'Borrowed')
INSERT INTO Borrowing (member_id, book_id, librarian_id, borrow_date, due_date, return_date, status) VALUES
(1, 1, 1, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), NULL, 'Borrowed'),

-- Overdue Record 1
(2, 3, 1, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), NULL, 'Borrowed'),

-- Overdue Record 2
(3, 3, 2, DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 11 DAY), NULL, 'Borrowed'),

-- Active Borrowing
(4, 3, 2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), NULL, 'Borrowed'),

-- Returned Record
(5, 5, 1, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_SUB(CURDATE(), INTERVAL 16 DAY), DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Returned'),

-- Active Borrowing
(1, 5, 2, DATE_SUB(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), NULL, 'Borrowed'),

-- Overdue Record 3
(2, 9, 1, DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL 1 DAY), NULL, 'Borrowed'),

-- Active Borrowing
(3, 9, 2, DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), NULL, 'Borrowed'),

-- Returned Record
(4, 10, 1, DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), CURDATE(), 'Returned'),

-- Active Borrowing
(5, 10, 2, DATE_SUB(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 12 DAY), NULL, 'Borrowed'),

-- Active Borrowing
(1, 10, 1, DATE_SUB(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), NULL, 'Borrowed');

-- 8. Insert Reservations
INSERT INTO Reservations (member_id, book_id, reservation_date, status) VALUES
(1, 3, DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Pending'),
(2, 9, DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Completed'),
(3, 1, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 'Cancelled'),
(4, 2, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Pending'),
(5, 3, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 'Completed');
