USE library_management_system;

-- 1. BorrowBook Procedure
DROP PROCEDURE IF EXISTS BorrowBook;

DELIMITER //

CREATE PROCEDURE BorrowBook(
    IN p_member_id INT,
    IN p_book_id INT,
    IN p_librarian_id INT
)
BEGIN
    -- Check if the book has available copies
    IF (SELECT available_copies FROM Books WHERE book_id = p_book_id) > 0 THEN

        -- Insert a new borrowing record
        INSERT INTO Borrowing(
            member_id,
            book_id,
            librarian_id,
            borrow_date,
            due_date,
            status
        )
        VALUES(
            p_member_id,
            p_book_id,
            p_librarian_id,
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 14 DAY),
            'Borrowed'
        );

        -- Decrease available copies
        UPDATE Books
        SET available_copies = available_copies - 1
        WHERE book_id = p_book_id;

    ELSE
        -- Raise an error if no copies are available
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Book is not available';
    END IF;
END //

DELIMITER ;


-- 2. ReturnBook Procedure
DROP PROCEDURE IF EXISTS ReturnBook;

DELIMITER //

CREATE PROCEDURE ReturnBook(
    IN p_borrow_id INT
)
BEGIN
    -- Check if the record exists and is currently 'Borrowed'
    IF EXISTS (SELECT 1 FROM Borrowing WHERE borrow_id = p_borrow_id AND status = 'Borrowed') THEN
        
        -- Update borrowing record to 'Returned'
        UPDATE Borrowing
        SET 
            return_date = CURDATE(),
            status = 'Returned'
        WHERE borrow_id = p_borrow_id
        AND status = 'Borrowed';

        -- Increase available copies
        UPDATE Books
        SET available_copies = available_copies + 1
        WHERE book_id = (
            SELECT book_id
            FROM Borrowing
            WHERE borrow_id = p_borrow_id
        );
        
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid borrowing record or book is already returned';
    END IF;
END //

DELIMITER ;

-- =======================================================
-- Test Calls (Commented out)
-- =======================================================

-- Test: Borrow an available book
-- CALL BorrowBook(1, 4, 1);

-- Test: Return the book
-- CALL ReturnBook(12); -- Adjust borrow_id based on the insertion

-- Test: Borrow an unavailable book (Should fail, Book 3 has 0 available_copies)
-- CALL BorrowBook(1, 3, 1);
