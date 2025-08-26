-- create a database named library_management
CREATE DATABASE library_management;
USE library_management;

-- Books Table
CREATE TABLE Books (
    BOOK_ID INT PRIMARY KEY AUTO_INCREMENT,
    TITLE VARCHAR(150) NOT NULL,
    AUTHOR VARCHAR(150) NOT NULL,
    GENRE VARCHAR(50),
    YEAR_PUBLISHED INT,
    AVAILABLE_COPIES INT DEFAULT 0
    );
    
-- Members Table
CREATE TABLE Members (
MEMBER_ID INT AUTO_INCREMENT PRIMARY KEY,
NAME VARCHAR(255) NOT NULL,
EMAIL VARCHAR(255) UNIQUE NOT NULL,
PHONE_NO INT(15),
ADDRESS TEXT,
MEMBERSHIP_DATE DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- BorrowingRecords Table
CREATE TABLE BorrowingRecords (
BORROW_ID INT PRIMARY KEY AUTO_INCREMENT,
MEMBER_ID INT NOT NULL,
BOOK_ID INT NOT NULL,
BORROW_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
RETURN_DATE DATETIME DEFAULT NULL,
    
FOREIGN KEY (MEMBER_ID) REFERENCES Members(MEMBER_ID),
FOREIGN KEY (BOOK_ID) REFERENCES Books(BOOK_ID)
);

-- Insert sample into Books table
INSERT INTO Books (TITLE, AUTHOR, GENRE, YEAR_PUBLISHED, AVAILABLE_COPIES)
VALUES
('400 DAYS', 'Chethan Bhagat', 'Mystery', 2021, 4),
('Lazarus', 'Lars Kepler', 'Thriller', 2018, 5),
('Part of the Family', 'Charlotte Philby', 'Thriller', 2020, 3),
('The Night Circus', 'Erin Morgenstern', 'Fantasy', 2011, 2),
('The Road', 'Cormac McCarthy', 'Fiction', 2006, 6);

-- Insert sample into Members table
INSERT INTO Members (NAME, EMAIL, PHONE_NO, ADDRESS, MEMBERSHIP_DATE)
VALUES
('Allan', 'alan@gmail.com', '9874567890', '123 Maple St', '2023-01-15'),
('Robin', 'robin@gmail.com', '9125678901', '456 Oak St', '2023-03-10'),
('Davis', 'davis@gmail.com', '7336789012', '789 Pine St', '2023-05-05'),
('Preethi', 'preethi@gmail.com', '7377890123', '135 Elm St', '2023-06-20'),
('Charles', 'charles@gmail.com', '9548901234', '246 Cedar St', '2023-07-11'),
('Sethu', 'sethu@gmail.com', '9481234567', '999 Sunset Blvd', '2025-08-20');

-- Insert sample into BorrowingRecords table
INSERT INTO BorrowingRecords (MEMBER_ID, BOOK_ID, BORROW_DATE, RETURN_DATE)
VALUES
(1, 1, '2025-07-01 10:00:00', NULL),
(1, 2, '2025-06-01 09:00:00', '2025-06-20 12:00:00'),
(2, 3, '2025-07-15 14:00:00', NULL),
(3, 4, '2025-05-10 08:00:00', '2025-05-25 16:00:00'),
(4, 5, '2025-06-10 11:00:00', NULL),
(5, 1, '2025-07-20 15:00:00', NULL),
(1, 4, '2025-08-22 14:30:00', NULL),
(2, 1, '2025-08-01 10:00:00', NULL),
(3, 1, '2025-08-02 11:00:00', NULL),
(4, 1, '2025-08-03 12:00:00', NULL),
(5, 1, '2025-08-04 13:00:00', NULL),
(1, 1, '2025-08-05 14:00:00', NULL),
(2, 1, '2025-08-06 15:00:00', NULL),
(3, 1, '2025-08-07 16:00:00', NULL),
(4, 1, '2025-08-08 17:00:00', NULL);

-- Retrieve a list of books currently borrowed by a specific member
SELECT b.BOOK_ID, b.TITLE, b.AUTHOR, br.BORROW_DATE
FROM BorrowingRecords br
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
WHERE br.MEMBER_ID = 1
  AND br.RETURN_DATE IS NULL;
  
  -- Find members who have overdue books (borrowed more than 30 days ago, not returned)
SELECT DISTINCT m.MEMBER_ID, m.NAME, b.TITLE, br.BORROW_DATE
FROM BorrowingRecords br
JOIN Members m ON br.MEMBER_ID = m.MEMBER_ID
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
WHERE br.RETURN_DATE IS NULL
AND br.BORROW_DATE < NOW() - INTERVAL 30 DAY;

-- Retrieve books by genre along with the count of available copies
SELECT GENRE, 
COUNT(*) AS NUMBER_OF_BOOKS, 
SUM(AVAILABLE_COPIES) AS TOTAL_AVAILABLE_COPIES
FROM Books
GROUP BY GENRE
ORDER BY 3 DESC;

-- Find the most borrowed book(s) overall
SELECT b.BOOK_ID, b.TITLE, COUNT(*) AS TIMES_BORROWED
FROM BorrowingRecords br
JOIN Books b ON br.BOOK_ID = b.BOOK_ID
GROUP BY b.BOOK_ID, b.TITLE
ORDER BY TIMES_BORROWED DESC
LIMIT 2;

-- Retrieve members who have borrowed books from at least three different genres
SELECT 
m.MEMBER_ID,
m.NAME,
COUNT(DISTINCT b.GENRE) AS GENRE_COUNT
FROM 
BorrowingRecords br
JOIN 
Books b ON br.BOOK_ID = b.BOOK_ID
JOIN 
Members m ON br.MEMBER_ID = m.MEMBER_ID
GROUP BY 
m.MEMBER_ID, m.NAME
HAVING 
COUNT(DISTINCT b.GENRE) >= 3;

-- Reporting and Analytics
-- Calculate the total number of books borrowed per month
SELECT DATE_FORMAT(BORROW_DATE, '%Y-%m') AS BORROW_MONTH, COUNT(*) AS TOTAL_BORROWED
FROM BorrowingRecords
GROUP BY BORROW_MONTH
ORDER BY BORROW_MONTH;

-- Find the top three most active members based on the number of books borrowed
SELECT M.NAME, COUNT(*) AS TOTAL_BORROWED
FROM BorrowingRecords BR
JOIN Members M ON BR.MEMBER_ID = M.MEMBER_ID
GROUP BY M.MEMBER_ID, M.NAME
ORDER BY TOTAL_BORROWED DESC
LIMIT 3;

-- Retrieve authors whose books have been borrowed at least 10 times
SELECT B.AUTHOR, COUNT(*) AS TOTAL_BORROWED
FROM BorrowingRecords BR
JOIN Books B ON BR.BOOK_ID = B.BOOK_ID
GROUP BY B.AUTHOR
HAVING COUNT(*) >= 10;

-- Identify members who have never borrowed a book
SELECT M.NAME, M.EMAIL
FROM Members M
LEFT JOIN BorrowingRecords BR ON M.MEMBER_ID = BR.MEMBER_ID
WHERE BR.BORROW_ID IS NULL;
