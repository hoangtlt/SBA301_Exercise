USE LibraryDB;
GO

-- 1. Create tables if they do not exist (matching JPA / Hibernate schema)
IF OBJECT_ID('dbo.STUDENTS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.STUDENTS (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        email VARCHAR(150) NOT NULL CONSTRAINT UK_STUDENT_EMAIL UNIQUE,
        first_name VARCHAR(80) NOT NULL,
        last_name VARCHAR(80) NOT NULL,
        gpa FLOAT NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.BOOKS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BOOKS (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        isbn VARCHAR(30) NOT NULL CONSTRAINT UK_BOOK_ISBN UNIQUE,
        title VARCHAR(200) NOT NULL,
        author VARCHAR(120) NOT NULL
    );
END
GO

IF OBJECT_ID('dbo.STUDENTS_BOOKS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.STUDENTS_BOOKS (
        student_id BIGINT NOT NULL,
        book_id BIGINT NOT NULL,
        CONSTRAINT PK_STUDENTS_BOOKS PRIMARY KEY (student_id, book_id),
        CONSTRAINT UK_STUDENT_BOOK UNIQUE (student_id, book_id),
        CONSTRAINT FK_STUDENTS_BOOKS_STUDENT FOREIGN KEY (student_id) REFERENCES dbo.STUDENTS(id) ON DELETE CASCADE,
        CONSTRAINT FK_STUDENTS_BOOKS_BOOK FOREIGN KEY (book_id) REFERENCES dbo.BOOKS(id)
    );
END
GO

IF OBJECT_ID('dbo.BORROWINGS', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BORROWINGS (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        student_id BIGINT NOT NULL,
        book_id BIGINT NOT NULL,
        borrowed_date DATE NOT NULL,
        due_date DATE NOT NULL,
        status VARCHAR(20) NOT NULL,
        CONSTRAINT UK_BORROWING_STUDENT_BOOK_DATE UNIQUE (student_id, book_id, borrowed_date),
        CONSTRAINT FK_BORROWINGS_STUDENT FOREIGN KEY (student_id) REFERENCES dbo.STUDENTS(id),
        CONSTRAINT FK_BORROWINGS_BOOK FOREIGN KEY (book_id) REFERENCES dbo.BOOKS(id)
    );
END
GO

-- 2. Insert sample BOOKS (from KNOWLEDGEBASE & DemoRunner)
IF NOT EXISTS (SELECT 1 FROM dbo.BOOKS WHERE isbn = '978-001')
    INSERT INTO dbo.BOOKS (isbn, title, author) VALUES ('978-001', 'Hibernate Basics', 'FPT');

IF NOT EXISTS (SELECT 1 FROM dbo.BOOKS WHERE isbn = '978-002')
    INSERT INTO dbo.BOOKS (isbn, title, author) VALUES ('978-002', 'ORM Design', 'FPT');

IF NOT EXISTS (SELECT 1 FROM dbo.BOOKS WHERE isbn = '978-003')
    INSERT INTO dbo.BOOKS (isbn, title, author) VALUES ('978-003', 'Clean Code', 'Robert C. Martin');

IF NOT EXISTS (SELECT 1 FROM dbo.BOOKS WHERE isbn = '978-004')
    INSERT INTO dbo.BOOKS (isbn, title, author) VALUES ('978-004', 'Effective Java', 'Joshua Bloch');
GO

-- 3. Insert sample STUDENTS (from KNOWLEDGEBASE & DemoRunner)
IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS WHERE email = 's29@fu.edu.vn')
    INSERT INTO dbo.STUDENTS (email, first_name, last_name, gpa) VALUES ('s29@fu.edu.vn', 'Slot', 'TwentyNine', 8.0);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS WHERE email = 'an@fu.edu.vn')
    INSERT INTO dbo.STUDENTS (email, first_name, last_name, gpa) VALUES ('an@fu.edu.vn', 'An', 'Nguyen', 8.5);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS WHERE email = 'binh@fu.edu.vn')
    INSERT INTO dbo.STUDENTS (email, first_name, last_name, gpa) VALUES ('binh@fu.edu.vn', 'Binh', 'Tran', 7.8);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS WHERE email = 'cuong@fu.edu.vn')
    INSERT INTO dbo.STUDENTS (email, first_name, last_name, gpa) VALUES ('cuong@fu.edu.vn', 'Cuong', 'Le', 9.0);
GO

-- 4. Insert sample Many-to-Many associations (STUDENTS_BOOKS)
-- An mượn: 'Hibernate Basics' (978-001) và 'ORM Design' (978-002)
-- Binh mượn: 'Hibernate Basics' (978-001)
-- Slot 29 mượn: 'Hibernate Basics' (978-001) và 'ORM Design' (978-002)
-- Cuong mượn: 'Clean Code' (978-003) và 'Effective Java' (978-004)
DECLARE @AnId BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 'an@fu.edu.vn');
DECLARE @BinhId BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 'binh@fu.edu.vn');
DECLARE @S29Id BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 's29@fu.edu.vn');
DECLARE @CuongId BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 'cuong@fu.edu.vn');

DECLARE @Book1Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-001');
DECLARE @Book2Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-002');
DECLARE @Book3Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-003');
DECLARE @Book4Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-004');

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @AnId AND book_id = @Book1Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@AnId, @Book1Id);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @AnId AND book_id = @Book2Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@AnId, @Book2Id);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @BinhId AND book_id = @Book1Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@BinhId, @Book1Id);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @S29Id AND book_id = @Book1Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@S29Id, @Book1Id);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @S29Id AND book_id = @Book2Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@S29Id, @Book2Id);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @CuongId AND book_id = @Book3Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@CuongId, @Book3Id);

IF NOT EXISTS (SELECT 1 FROM dbo.STUDENTS_BOOKS WHERE student_id = @CuongId AND book_id = @Book4Id)
    INSERT INTO dbo.STUDENTS_BOOKS (student_id, book_id) VALUES (@CuongId, @Book4Id);
GO

-- 5. Insert sample Association Entity records (BORROWINGS)
DECLARE @AnId BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 'an@fu.edu.vn');
DECLARE @BinhId BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 'binh@fu.edu.vn');
DECLARE @S29Id BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 's29@fu.edu.vn');
DECLARE @CuongId BIGINT = (SELECT id FROM dbo.STUDENTS WHERE email = 'cuong@fu.edu.vn');

DECLARE @Book1Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-001');
DECLARE @Book2Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-002');
DECLARE @Book3Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-003');
DECLARE @Book4Id BIGINT = (SELECT id FROM dbo.BOOKS WHERE isbn = '978-004');

IF NOT EXISTS (SELECT 1 FROM dbo.BORROWINGS WHERE student_id = @AnId AND book_id = @Book1Id AND borrowed_date = '2026-10-01')
    INSERT INTO dbo.BORROWINGS (student_id, book_id, borrowed_date, due_date, status)
    VALUES (@AnId, @Book1Id, '2026-10-01', '2026-10-15', 'BORROWED');

IF NOT EXISTS (SELECT 1 FROM dbo.BORROWINGS WHERE student_id = @AnId AND book_id = @Book2Id AND borrowed_date = '2026-09-01')
    INSERT INTO dbo.BORROWINGS (student_id, book_id, borrowed_date, due_date, status)
    VALUES (@AnId, @Book2Id, '2026-09-01', '2026-09-15', 'RETURNED');

IF NOT EXISTS (SELECT 1 FROM dbo.BORROWINGS WHERE student_id = @BinhId AND book_id = @Book1Id AND borrowed_date = '2026-10-05')
    INSERT INTO dbo.BORROWINGS (student_id, book_id, borrowed_date, due_date, status)
    VALUES (@BinhId, @Book1Id, '2026-10-05', '2026-10-20', 'BORROWED');

IF NOT EXISTS (SELECT 1 FROM dbo.BORROWINGS WHERE student_id = @S29Id AND book_id = @Book1Id AND borrowed_date = '2026-10-26')
    INSERT INTO dbo.BORROWINGS (student_id, book_id, borrowed_date, due_date, status)
    VALUES (@S29Id, @Book1Id, '2026-10-26', '2026-11-09', 'BORROWED');

IF NOT EXISTS (SELECT 1 FROM dbo.BORROWINGS WHERE student_id = @CuongId AND book_id = @Book3Id AND borrowed_date = '2026-10-10')
    INSERT INTO dbo.BORROWINGS (student_id, book_id, borrowed_date, due_date, status)
    VALUES (@CuongId, @Book3Id, '2026-10-10', '2026-10-24', 'BORROWED');

IF NOT EXISTS (SELECT 1 FROM dbo.BORROWINGS WHERE student_id = @CuongId AND book_id = @Book4Id AND borrowed_date = '2026-09-15')
    INSERT INTO dbo.BORROWINGS (student_id, book_id, borrowed_date, due_date, status)
    VALUES (@CuongId, @Book4Id, '2026-09-15', '2026-09-29', 'OVERDUE');
GO
