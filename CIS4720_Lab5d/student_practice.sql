/* ==========================================================================
   student_practice.sql
   CIS 4720 Database Management and SQL
   In Class Lab 5d

   WHAT THIS FILE IS
   Your working file for Lab 5d. The first two statements are written for
   you. Everything from Step 1 down is yours to write, under the heading
   that is already there for each step.

   HOW TO USE IT
   Run one statement at a time. Put the cursor on it and press Ctrl + E
   twice, or right click and choose Run Current Query. Do not run the whole
   file in one go, because Step 8 creates a function and that step has to be
   run as a single block on its own.

   LABELING AND COMMENTING IS REQUIRED
   Above every statement you write, put a short comment in your own words
   saying what it does. The headings below are already numbered, so keep
   your work underneath the right one. The comments are graded.
   ========================================================================== */


-- =================================================================
-- SETUP. Run these two first, in this order
-- =================================================================

-- Every schema on this server. Look for cis_students_db afterwards.
show databases;

-- Make the schema for this lab. IF NOT EXISTS means it is safe to run
-- twice, and it will not complain if you already made it.
create database if not exists cis_students_db;


-- =================================================================
-- POINT YOURSELF AT THE NEW SCHEMA
-- =================================================================

-- Everything below has to land in cis_students_db, not in the schema you
-- connected to. This line switches the session over.
--
-- IMPORTANT: if your tables keep appearing in the wrong place, your tool
-- is opening a new connection for each statement and this line is being
-- forgotten. Step 3 of the lab tells you how to fix that for good by
-- adding a second SQLTools connection that points at cis_students_db.
use cis_students_db;


SELECT DATABASE();


-- ######################################################################
-- YOUR WORK STARTS BELOW THIS LINE
--
-- You write the SQL for Steps 1 through 7 yourself. The handout gives you
-- the specification, the data and the result you should get.
--
-- Steps 8, 9 and 10 are printed in the handout for you to copy, because
-- you have not written a function or a trigger before.
--
-- Everything in this file runs in VS Code, including the function and
-- the triggers. Run one statement at a time: put the cursor on it and
-- press Ctrl + E twice, or select it and run the selection.
-- ######################################################################


-- =================================================================
-- STEP 1. Create the students table, then describe it
-- =================================================================

-- Create the students table
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(40) NOT NULL,
    last_name VARCHAR(40) NOT NULL,
    gpa FLOAT(4,2) NULL
);

-- Describe table

DESCRIBE students;

-- =================================================================
-- STEP 2. Insert four rows using NULL for student_id and gpa
-- =================================================================

-- Insert four rows with NULL

INSERT INTO students
VALUES
(NULL, 'Jenna', 'Wilson', NULL),
(NULL, 'Robert', 'Reese', NULL),
(NULL, 'Maria Elena', 'Jimenez', NULL),
(NULL, 'Inder', 'Singh', NULL);

-- Select last insert ID

SELECT LAST_INSERT_ID();

-- Select students data

SELECT * FROM students;


-- =================================================================
-- STEP 3. Insert two more rows, naming the columns first
-- =================================================================

-- Insert two more rows

INSERT INTO students (first_name, last_name)
VALUES
('Rita', 'Nunez'),
('James', 'Toor');


SELECT LAST_INSERT_ID();


SELECT * FROM students;



-- =================================================================
-- STEP 4. Delete James Toor
-- =================================================================

-- Select James Toor

SELECT *
FROM students
WHERE first_name = 'James'
AND last_name = 'Toor';

-- Delete

DELETE FROM students
WHERE first_name = 'James'
AND last_name = 'Toor';



SELECT * FROM students;


-- =================================================================
-- STEP 5. Create the test_scores table
-- =================================================================

-- Create table

CREATE TABLE test_scores (
    test_score_id INT AUTO_INCREMENT PRIMARY KEY,
    test_name VARCHAR(20) NOT NULL,
    student_id INT NOT NULL,
    score FLOAT NULL,
    FOREIGN KEY (student_id)
        REFERENCES students(student_id)
);

-- Describe

DESCRIBE test_scores;


-- =================================================================
-- STEP 6. Insert the ten test score rows
-- =================================================================

-- Input test score rows

INSERT INTO test_scores
VALUES
(NULL, 'quiz1', 1, 90),
(NULL, 'quiz1', 2, 85),
(NULL, 'quiz1', 3, 95),
(NULL, 'quiz2', 1, 80),
(NULL, 'quiz2', 2, 72),
(NULL, 'quiz2', 3, 88),
(NULL, 'quiz2', 4, 91),
(NULL, 'quiz3', 2, 95),
(NULL, 'quiz3', 3, 94),
(NULL, 'quiz3', 4, 74);

-- Check records

SELECT * FROM test_scores;

-- =================================================================
-- STEP 7. Create the student_scores view from a LEFT OUTER JOIN,
--         then query it twice
-- =================================================================

-- Create view then query

CREATE VIEW student_scores AS
SELECT
    students.student_id,
    CONCAT(students.first_name, ' ', students.last_name)
        AS student_name,
    test_scores.test_name,
    test_scores.score
FROM students
LEFT OUTER JOIN test_scores
    ON students.student_id = test_scores.student_id;

-- Check
SELECT * FROM student_scores;


SELECT *
FROM student_scores
WHERE student_id = 3;

-- =================================================================
-- STEP 8. Create the calculate_gpa function
--
-- Copy the block from the handout. It is one statement from CREATE
-- FUNCTION down to END, so select the whole thing and run the selection.
--
-- If you find a version online wrapped in DELIMITER $$ and DELIMITER ;
-- leave those lines out and drop the $$ after END. They are instructions
-- to the command prompt program, not SQL, and the server rejects them.
-- =================================================================

-- Create function
CREATE FUNCTION calculate_gpa(p_student_id INT)
RETURNS DECIMAL(4,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_gpa DECIMAL(4,2);

    SELECT ROUND(AVG(score), 2)
    INTO v_gpa
    FROM test_scores
    WHERE student_id = p_student_id
      AND score IS NOT NULL;

    RETURN IFNULL(v_gpa, 0.00);
END

-- Check

SHOW CREATE FUNCTION calculate_gpa;


-- =================================================================
-- STEP 9. Run the function and fill in every gpa
-- =================================================================

-- Update then run function

UPDATE students
SET gpa = calculate_gpa(student_id);

-- Check
SELECT * FROM students;


-- =================================================================
-- STEP 10. Create the triggers that recalculate the gpa
--
-- Two statements, each one running from CREATE TRIGGER down to its own
-- END. Run them one at a time. No DELIMITER needed here either.
--
-- Afterwards add a score or change one, and check that the gpa moved on
-- its own.
-- =================================================================

-- Create the first trigger, insert
CREATE TRIGGER trg_scores_after_insert
AFTER INSERT ON test_scores
FOR EACH ROW
BEGIN
    UPDATE students
    SET gpa = calculate_gpa(NEW.student_id)
    WHERE student_id = NEW.student_id;
END

-- Create second trigger, update

CREATE TRIGGER trg_scores_after_update
AFTER UPDATE ON test_scores
FOR EACH ROW
BEGIN
    UPDATE students
    SET gpa = calculate_gpa(NEW.student_id)
    WHERE student_id = NEW.student_id;
END

-- Check

SHOW TRIGGERS;



SELECT student_id, first_name, gpa
FROM students
WHERE student_id = 1;

-- Check GPA

INSERT INTO test_scores
VALUES (NULL, 'quiz4', 1, 100);


SELECT * FROM student_scores;


-- =================================================================
-- STEP 11. Push this file to GitHub
-- Nothing to write here. Follow the handout.
-- =================================================================
