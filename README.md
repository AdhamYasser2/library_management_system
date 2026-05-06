# Library Management System Database

This is a database-based project designed to help a library manage books, members, librarians, borrowing operations, book returns, reservations, and fines.

## Files

- `00_setup.sql`: Creates and selects the `library_management_system` database.
- `01_create_tables.sql`: Creates the database tables with proper constraints and relationships.
- `02_insert_sample_data.sql`: Inserts sample data for testing.
- `03_queries.sql`: Contains various SQL queries for reporting.
- `04_procedures.sql`: Contains stored procedures for borrowing and returning books.
- `05_triggers.sql`: Contains triggers for automatic fine calculation and data integrity.

## How to Run

Execute the SQL files in numerical order against a MySQL 8.x server:

1. Run `00_setup.sql` to initialize the database.
2. Run `01_create_tables.sql` to build the schema.
3. Run `02_insert_sample_data.sql` to populate the tables.
4. Run `03_queries.sql` to execute reports.
5. Run `04_procedures.sql` to create procedures.
6. Run `05_triggers.sql` to create triggers.
