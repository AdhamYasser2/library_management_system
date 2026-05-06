import mysql.connector
from mysql.connector import Error

# Database Connection Settings
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "",
    "database": "library_management_system"
}

def connect_db():
    """Establishes connection to MySQL"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        if conn.is_connected():
            return conn
    except Error as e:
        print(f"Error connecting to database: {e}")
        return None

def fetch_query(query, params=None):
    """Helper function to execute SELECT queries and return a list of dictionaries."""
    conn = connect_db()
    if not conn:
        return []
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute(query, params or ())
        return cursor.fetchall()
    except Error as e:
        print(f"Query Error: {e}")
        return []
    finally:
        if 'cursor' in locals():
            cursor.close()
        conn.close()

# --- Query Functions for the Routes ---

def get_all_books():
    return fetch_query("SELECT book_id, title, isbn, publisher, publish_year, total_copies, available_copies FROM Books")

def get_available_books():
    return fetch_query("SELECT book_id, title, available_copies FROM Books WHERE available_copies > 0")

def get_borrowed_books():
    query = """
        SELECT br.borrow_id, m.full_name as member, b.title as book, br.borrow_date, br.due_date 
        FROM Borrowing br
        JOIN Members m ON br.member_id = m.member_id
        JOIN Books b ON br.book_id = b.book_id
        WHERE br.status = 'Borrowed'
    """
    return fetch_query(query)

def get_books_with_categories():
    query = """
        SELECT b.book_id, b.title, c.category_name, b.available_copies
        FROM Books b
        JOIN Categories c ON b.category_id = c.category_id
    """
    return fetch_query(query)

def get_most_borrowed_books():
    query = """
        SELECT b.title, COUNT(br.borrow_id) AS times_borrowed
        FROM Borrowing br
        JOIN Books b ON br.book_id = b.book_id
        GROUP BY b.title
        ORDER BY times_borrowed DESC
    """
    return fetch_query(query)

def get_unpaid_fines():
    query = """
        SELECT m.full_name as member, b.title as book, f.fine_amount, f.paid_status
        FROM Fines f
        JOIN Borrowing br ON f.borrow_id = br.borrow_id
        JOIN Members m ON br.member_id = m.member_id
        JOIN Books b ON br.book_id = b.book_id
        WHERE f.paid_status = 'Unpaid'
    """
    return fetch_query(query)

def get_members():
    return fetch_query("SELECT member_id, full_name, email, phone, department, registration_date FROM Members")

def get_authors():
    return fetch_query("SELECT author_id, author_name FROM Authors")

def get_librarians():
    return fetch_query("SELECT librarian_id, full_name, email, phone FROM Librarians")

def get_reservations():
    query = """
        SELECT r.reservation_id, m.full_name as member, b.title as book, r.reservation_date, r.status
        FROM Reservations r
        JOIN Members m ON r.member_id = m.member_id
        JOIN Books b ON r.book_id = b.book_id
    """
    return fetch_query(query)

# --- Stored Procedure Callers ---

def call_borrow_book(member_id, book_id, librarian_id):
    """Executes the BorrowBook stored procedure."""
    conn = connect_db()
    if not conn:
        return False, "Database connection failed"
    try:
        cursor = conn.cursor()
        cursor.callproc('BorrowBook', (member_id, book_id, librarian_id))
        conn.commit()
        return True, "Book borrowed successfully!"
    except Error as e:
        return False, str(e)
    finally:
        if 'cursor' in locals():
            cursor.close()
        conn.close()

def call_return_book(borrow_id):
    """Executes the ReturnBook stored procedure."""
    conn = connect_db()
    if not conn:
        return False, "Database connection failed"
    try:
        cursor = conn.cursor()
        cursor.callproc('ReturnBook', (borrow_id,))
        conn.commit()
        return True, "Book returned successfully!"
    except Error as e:
        return False, str(e)
    finally:
        if 'cursor' in locals():
            cursor.close()
        conn.close()
