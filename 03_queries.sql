USE library_management_system;

-- Q1: Projection — Show selected columns from books
SELECT title, publish_year 
FROM Books;

-- Q2: Selection — Show available books only
SELECT title, available_copies 
FROM Books 
WHERE available_copies > 0;

-- Q3: JOIN — Books with their categories
SELECT b.title, c.category_name
FROM Books b
JOIN Categories c ON b.category_id = c.category_id;

-- Q4: Multiple JOIN — Borrowing details with member, book, librarian
SELECT 
    m.full_name AS member_name, 
    b.title AS book_title,
    l.full_name AS librarian_name, 
    br.borrow_date, 
    br.due_date, 
    br.status
FROM Borrowing br
JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
JOIN Librarians l ON br.librarian_id = l.librarian_id;

-- Q5: Aggregation — Count books per category
SELECT 
    c.category_name, 
    COUNT(b.book_id) AS total_books
FROM Categories c
LEFT JOIN Books b ON c.category_id = b.category_id
GROUP BY c.category_name;

-- Q6: Aggregation with ORDER BY - Most borrowed books
SELECT 
    b.title, 
    COUNT(br.borrow_id) AS times_borrowed
FROM Borrowing br
JOIN Books b ON br.book_id = b.book_id
GROUP BY b.title
ORDER BY times_borrowed DESC;

-- Q7: Subquery - Books never borrowed
SELECT title 
FROM Books
WHERE book_id NOT IN (
    SELECT book_id 
    FROM Borrowing
);

-- Q8: Overdue Books - Currently overdue books
SELECT 
    m.full_name, 
    b.title, 
    br.due_date
FROM Borrowing br
JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE br.due_date < CURDATE() 
  AND br.status = 'Borrowed';

-- Q9: Fines Report - Members with unpaid fines
SELECT 
    m.full_name, 
    b.title, 
    f.fine_amount, 
    f.paid_status
FROM Fines f
JOIN Borrowing br ON f.borrow_id = br.borrow_id
JOIN Members m ON br.member_id = m.member_id
JOIN Books b ON br.book_id = b.book_id
WHERE f.paid_status = 'Unpaid';

-- Q10: Bonus - Borrowing history for a specific member
SELECT 
    b.title, 
    br.borrow_date, 
    br.due_date, 
    br.return_date, 
    br.status
FROM Borrowing br
JOIN Books b ON br.book_id = b.book_id
WHERE br.member_id = 1;

-- Q11: Bonus - Books by a specific author
SELECT 
    b.title, 
    a.author_name
FROM Books b
JOIN Book_Authors ba ON b.book_id = ba.book_id
JOIN Authors a ON ba.author_id = a.author_id
WHERE a.author_name = 'Ahmed Khaled Tawfik';

-- Q12: Bonus - Total fines collected vs unpaid
SELECT 
    paid_status, 
    SUM(fine_amount) AS total_amount
FROM Fines 
GROUP BY paid_status;
