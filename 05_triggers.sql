USE library_management_system;

-- 1. Fine Calculation Trigger
DROP TRIGGER IF EXISTS calculate_fine_after_return;

DELIMITER //

CREATE TRIGGER calculate_fine_after_return
AFTER UPDATE ON Borrowing
FOR EACH ROW
BEGIN
    -- Check if the book was just returned and is overdue
    IF NEW.return_date IS NOT NULL 
       AND OLD.status = 'Borrowed'
       AND NEW.status = 'Returned'
       AND NEW.return_date > NEW.due_date THEN

        -- Insert a new fine record (5 EGP per late day)
        INSERT INTO Fines(
            borrow_id,
            fine_amount,
            paid_status
        )
        VALUES(
            NEW.borrow_id,
            DATEDIFF(NEW.return_date, NEW.due_date) * 5,
            'Unpaid'
        );

    END IF;
END //

DELIMITER ;


-- 2. Prevent Invalid Available Copies Trigger
DROP TRIGGER IF EXISTS prevent_negative_available_copies;

DELIMITER //

CREATE TRIGGER prevent_negative_available_copies
BEFORE UPDATE ON Books
FOR EACH ROW
BEGIN
    -- Prevent negative available copies
    IF NEW.available_copies < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Available copies cannot be negative';
    END IF;

    -- Prevent available copies from exceeding total copies
    IF NEW.available_copies > NEW.total_copies THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Available copies cannot exceed total copies';
    END IF;
END //

DELIMITER ;

-- =======================================================
-- Test Scenarios (Commented out)
-- =======================================================

-- Test fine trigger: Return an overdue book
-- UPDATE Borrowing 
-- SET return_date = DATE_ADD(due_date, INTERVAL 3 DAY), status = 'Returned' 
-- WHERE borrow_id = 2 AND status = 'Borrowed';
-- SELECT * FROM Fines;  -- Should show a new fine of 15 EGP

-- Test negative copies trigger:
-- UPDATE Books 
-- SET available_copies = -1 
-- WHERE book_id = 1;
-- Should fail with error: 'Available copies cannot be negative'
