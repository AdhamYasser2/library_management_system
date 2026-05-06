import base64
import urllib.request
import sys

mermaid_code = """
erDiagram
    Members {
        int member_id PK
        string full_name
        string email
        string phone
        string department
        date registration_date
    }
    Librarians {
        int librarian_id PK
        string full_name
        string email
        string phone
    }
    Categories {
        int category_id PK
        string category_name
    }
    Authors {
        int author_id PK
        string author_name
    }
    Books {
        int book_id PK
        string title
        string isbn
        int category_id FK
        string publisher
        int publish_year
        int total_copies
        int available_copies
    }
    Book_Authors {
        int book_id PK,FK
        int author_id PK,FK
    }
    Borrowing {
        int borrow_id PK
        int member_id FK
        int book_id FK
        int librarian_id FK
        date borrow_date
        date due_date
        date return_date
        string status
    }
    Fines {
        int fine_id PK
        int borrow_id FK
        decimal fine_amount
        string paid_status
    }
    Reservations {
        int reservation_id PK
        int member_id FK
        int book_id FK
        date reservation_date
        string status
    }

    Members ||--o{ Borrowing : makes
    Books ||--o{ Borrowing : is_borrowed
    Librarians ||--o{ Borrowing : records
    Categories ||--o{ Books : contains
    Books ||--o{ Book_Authors : has
    Authors ||--o{ Book_Authors : writes
    Borrowing ||--o| Fines : generates
    Members ||--o{ Reservations : places
    Books ||--o{ Reservations : is_reserved
"""

try:
    graphbytes = mermaid_code.encode("utf-8")
    base64_bytes = base64.urlsafe_b64encode(graphbytes)
    base64_string = base64_bytes.decode("utf-8")
    
    url = "https://mermaid.ink/img/" + base64_string
    
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as response:
        with open("/Users/adhamyasser/Desktop/Project DB/ERD.png", "wb") as f:
            f.write(response.read())
            
    print("ERD.png generated successfully.")
except Exception as e:
    print(f"Error generating ERD: {e}")
    sys.exit(1)
