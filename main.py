import mysql.connector
from mysql.connector import Error

# ---------------------------------------------------------
# Database Connection Settings
# ---------------------------------------------------------
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "library_management_system"
}

def connect_db():
    """
    Connects to the MySQL database using the configuration above.
    Returns the connection object if successful, otherwise None.
    """
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            return conn
    except Error as e:
        print(f"\n[Error] Could not connect to database: {e}")
        return None

def show_all_books():
    """Shows all books in the database."""
    conn = connect_db()
    if not conn:
        return

    try:
        # Use dictionary=True so we can access columns by name instead of index
        cursor = conn.cursor(dictionary=True)
        query = "SELECT book_id, title, available_copies, total_copies FROM Books"
        cursor.execute(query)
        books = cursor.fetchall()
        
        if not books:
            print("\nNo books found in the database.")
        else:
            print("\n--- All Books ---")
            for book in books:
                print(f"Book ID: {book['book_id']}")
                print(f"Title: {book['title']}")
                print(f"Available Copies: {book['available_copies']} / {book['total_copies']}")
                print("-" * 40)
    except Error as e:
        print(f"\n[Error] Executing query failed: {e}")
    finally:
        cursor.close()
        conn.close()

def show_available_books():
    """Shows only books that have available copies > 0."""
    conn = connect_db()
    if not conn:
        return

    try:
        cursor = conn.cursor(dictionary=True)
        query = "SELECT book_id, title, available_copies FROM Books WHERE available_copies > 0"
        cursor.execute(query)
        books = cursor.fetchall()
        
        if not books:
            print("\nNo available books at the moment.")
        else:
            print("\n--- Available Books ---")
            for book in books:
                print(f"Book ID: {book['book_id']}")
                print(f"Title: {book['title']}")
                print(f"Available Copies: {book['available_copies']}")
                print("-" * 40)
    except Error as e:
        print(f"\n[Error] Executing query failed: {e}")
    finally:
        cursor.close()
        conn.close()

def show_borrowed_books():
    """Shows all books currently borrowed using a JOIN query."""
    conn = connect_db()
    if not conn:
        return

    try:
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT br.borrow_id, m.full_name, b.title, br.due_date 
            FROM Borrowing br
            JOIN Members m ON br.member_id = m.member_id
            JOIN Books b ON br.book_id = b.book_id
            WHERE br.status = 'Borrowed'
        """
        cursor.execute(query)
        records = cursor.fetchall()
        
        if not records:
            print("\nNo currently borrowed books found.")
        else:
            print("\n--- Borrowed Books ---")
            for record in records:
                print(f"Borrow ID: {record['borrow_id']}")
                print(f"Member Name: {record['full_name']}")
                print(f"Book Title: {record['title']}")
                print(f"Due Date: {record['due_date']}")
                print("-" * 40)
    except Error as e:
        print(f"\n[Error] Executing query failed: {e}")
    finally:
        cursor.close()
        conn.close()

def show_books_with_categories():
    """Shows books along with their category names using JOIN."""
    conn = connect_db()
    if not conn:
        return

    try:
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT b.title, c.category_name
            FROM Books b
            JOIN Categories c ON b.category_id = c.category_id
        """
        cursor.execute(query)
        records = cursor.fetchall()
        
        if not records:
            print("\nNo books or categories found.")
        else:
            print("\n--- Books with Categories ---")
            for record in records:
                print(f"Title: {record['title']}")
                print(f"Category: {record['category_name']}")
                print("-" * 40)
    except Error as e:
        print(f"\n[Error] Executing query failed: {e}")
    finally:
        cursor.close()
        conn.close()

def show_most_borrowed_books():
    """Shows the most borrowed books using GROUP BY and ORDER BY."""
    conn = connect_db()
    if not conn:
        return

    try:
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT b.title, COUNT(br.borrow_id) AS times_borrowed
            FROM Borrowing br
            JOIN Books b ON br.book_id = b.book_id
            GROUP BY b.title
            ORDER BY times_borrowed DESC
        """
        cursor.execute(query)
        records = cursor.fetchall()
        
        if not records:
            print("\nNo borrowing history found.")
        else:
            print("\n--- Most Borrowed Books ---")
            for record in records:
                print(f"Title: {record['title']}")
                print(f"Times Borrowed: {record['times_borrowed']}")
                print("-" * 40)
    except Error as e:
        print(f"\n[Error] Executing query failed: {e}")
    finally:
        cursor.close()
        conn.close()

def show_unpaid_fines():
    """Shows members who have unpaid fines."""
    conn = connect_db()
    if not conn:
        return

    try:
        cursor = conn.cursor(dictionary=True)
        query = """
            SELECT m.full_name, b.title, f.fine_amount
            FROM Fines f
            JOIN Borrowing br ON f.borrow_id = br.borrow_id
            JOIN Members m ON br.member_id = m.member_id
            JOIN Books b ON br.book_id = b.book_id
            WHERE f.paid_status = 'Unpaid'
        """
        cursor.execute(query)
        records = cursor.fetchall()
        
        if not records:
            print("\nGreat! There are no unpaid fines.")
        else:
            print("\n--- Members with Unpaid Fines ---")
            for record in records:
                print(f"Member Name: {record['full_name']}")
                print(f"Book Title: {record['title']}")
                print(f"Fine Amount: {record['fine_amount']} EGP")
                print("-" * 40)
    except Error as e:
        print(f"\n[Error] Executing query failed: {e}")
    finally:
        cursor.close()
        conn.close()

def borrow_book():
    """
    Asks user for IDs and calls the BorrowBook stored procedure.
    """
    conn = connect_db()
    if not conn:
        return

    try:
        print("\n--- Borrow a Book ---")
        member_id = int(input("Enter Member ID: "))
        book_id = int(input("Enter Book ID: "))
        librarian_id = int(input("Enter Librarian ID: "))

        cursor = conn.cursor()
        
        # Calling the SQL stored procedure directly
        cursor.callproc('BorrowBook', (member_id, book_id, librarian_id))
        
        # Commit the transaction so the database saves the change
        conn.commit() 
        print("\n[Success] Book borrowed successfully.")
        
    except ValueError:
        print("\n[Error] Invalid input. Please enter numbers only for IDs.")
    except Error as e:
        # If the stored procedure raises an error (e.g., 'Book is not available'), it gets caught here
        print(f"\n[Database Error] Could not borrow book: {e}")
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        conn.close()

def return_book():
    """
    Asks user for borrow ID and calls the ReturnBook stored procedure.
    """
    conn = connect_db()
    if not conn:
        return

    try:
        print("\n--- Return a Book ---")
        borrow_id = int(input("Enter Borrow ID: "))

        cursor = conn.cursor()
        
        # Calling the SQL stored procedure directly
        cursor.callproc('ReturnBook', (borrow_id,))
        
        # Commit the transaction so the database saves the change
        conn.commit() 
        print("\n[Success] Book returned successfully.")
        
    except ValueError:
        print("\n[Error] Invalid input. Please enter a number for the Borrow ID.")
    except Error as e:
        print(f"\n[Database Error] Could not return book: {e}")
    finally:
        if 'cursor' in locals() and cursor is not None:
            cursor.close()
        conn.close()

def main_menu():
    """
    Shows the terminal menu and routes the user to the correct function.
    """
    while True:
        print("\n===============================")
        print("   Library Management System   ")
        print("===============================")
        print("1. Show all books")
        print("2. Show available books")
        print("3. Show borrowed books")
        print("4. Show books with categories")
        print("5. Show most borrowed books")
        print("6. Show members with unpaid fines")
        print("7. Borrow a book")
        print("8. Return a book")
        print("9. Exit")
        print("===============================")
        
        choice = input("Enter your choice (1-9): ")
        
        if choice == '1':
            show_all_books()
        elif choice == '2':
            show_available_books()
        elif choice == '3':
            show_borrowed_books()
        elif choice == '4':
            show_books_with_categories()
        elif choice == '5':
            show_most_borrowed_books()
        elif choice == '6':
            show_unpaid_fines()
        elif choice == '7':
            borrow_book()
        elif choice == '8':
            return_book()
        elif choice == '9':
            print("\nExiting the Library Management System. Goodbye!\n")
            break
        else:
            print("\n[Error] Invalid choice! Please enter a number between 1 and 9.")

# This runs when we start the script
if __name__ == "__main__":
    main_menu()
