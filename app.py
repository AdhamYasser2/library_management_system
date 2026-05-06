from flask import Flask, render_template, request, flash, redirect, url_for
import db

app = Flask(__name__)
# A secret key is required for Flask to use flash messages (session security) 
app.secret_key = 'super_secret_library_key'

@app.route('/')
def dashboard():
    """Renders the main dashboard page."""
    return render_template('dashboard.html')

@app.route('/books')
def all_books():
    """Shows all books."""
    data = db.get_all_books()
    return render_template('table_view.html', title="All Books", data=data)

@app.route('/available_books')
def available_books():
    """Shows available books."""
    data = db.get_available_books()
    return render_template('table_view.html', title="Available Books", data=data)

@app.route('/borrowed_books')
def borrowed_books():
    """Shows currently borrowed books."""
    data = db.get_borrowed_books()
    return render_template('table_view.html', title="Borrowed Books", data=data)

@app.route('/books_categories')
def books_categories():
    """Shows books along with their categories."""
    data = db.get_books_with_categories()
    return render_template('table_view.html', title="Books with Categories", data=data)

@app.route('/most_borrowed')
def most_borrowed():
    """Shows most borrowed books."""
    data = db.get_most_borrowed_books()
    return render_template('table_view.html', title="Most Borrowed Books", data=data)

@app.route('/unpaid_fines')
def unpaid_fines():
    """Shows members with unpaid fines."""
    data = db.get_unpaid_fines()
    return render_template('table_view.html', title="Unpaid Fines", data=data)

@app.route('/members')
def members():
    """Shows all members."""
    data = db.get_members()
    return render_template('table_view.html', title="Members", data=data)

@app.route('/authors')
def authors():
    """Shows all authors."""
    data = db.get_authors()
    return render_template('table_view.html', title="Authors", data=data)

@app.route('/librarians')
def librarians():
    """Shows all librarians."""
    data = db.get_librarians()
    return render_template('table_view.html', title="Librarians", data=data)

@app.route('/reservations')
def reservations():
    """Shows all reservations."""
    data = db.get_reservations()
    return render_template('table_view.html', title="Reservations", data=data)

@app.route('/borrow', methods=['GET', 'POST'])
def borrow_book():
    """Handles the Borrow Book form and process. Calls BorrowBook procedure."""
    if request.method == 'POST':
        member_id = request.form.get('member_id')
        book_id = request.form.get('book_id')
        librarian_id = request.form.get('librarian_id')
        
        success, message = db.call_borrow_book(member_id, book_id, librarian_id)
        if success:
            flash(message, "success")
        else:
            flash(f"Error: {message}", "danger")
            
        return redirect(url_for('borrow_book'))
        
    return render_template('borrow_form.html')

@app.route('/return', methods=['GET', 'POST'])
def return_book():
    """Handles the Return Book form and process. Calls ReturnBook procedure."""
    if request.method == 'POST':
        borrow_id = request.form.get('borrow_id')
        
        success, message = db.call_return_book(borrow_id)
        if success:
            flash(message, "success")
        else:
            flash(f"Error: {message}", "danger")
            
        return redirect(url_for('return_book'))
        
    return render_template('return_form.html')

if __name__ == '__main__':
    # Start the Flask development server on port 5001
    app.run(debug=True,host = "192.168.1.5", port=5001)
