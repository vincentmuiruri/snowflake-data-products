-----------------------------------------------------------------------------------------------------------
--                                        SNOWFLAKE TIME TRAVEL LAB                                      -- 
--               All commands/statements can be found via the link in the Video Description              --
-----------------------------------------------------------------------------------------------------------

-- Create a database
CREATE database IF NOT EXISTS demo_db;

-- Create a schema within the database
CREATE SCHEMA IF NOT EXISTS demo_db.demo_schema;

-- Switch to the newly created database and schema
USE DATABASE demo_db;
USE SCHEMA demo_db.demo_schema;

-- Create a permanent table within the schema
CREATE TABLE my_table (
    emp_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- Insert some rows into the table
INSERT INTO demo_db.demo_schema.my_table (emp_id, full_name, salary) VALUES (1, 'Alice Smith', 50000);
INSERT INTO demo_db.demo_schema.my_table (emp_id, full_name, salary) VALUES (2, 'Bob Johnson', 60000);
INSERT INTO demo_db.demo_schema.my_table (emp_id, full_name, salary) VALUES (3, 'Charlie Brown', 55000);
INSERT INTO demo_db.demo_schema.my_table (emp_id, full_name, salary) VALUES (4, 'Daisy Clark', 58000);
INSERT INTO demo_db.demo_schema.my_table (emp_id, full_name, salary) VALUES (5, 'Eve Davis', 62000);

-- Query table data
SELECT * FROM my_table;

-- Retrieve the current timestamp
SELECT CURRENT_TIMESTAMP();
--2024-05-31 03:54:09.742 -0700

-- Update a row in the table (change last name of Alice Smith)
UPDATE my_table
SET full_name = 'Alice Johnson'
WHERE emp_id = 1;

-- Delete a row from the table
DELETE FROM my_table WHERE emp_id = 2;

-- Query table data
SELECT * FROM my_table;

-----------------------------------------------------------------------------------------------------------
--                                    TIME TRAVEL WHILE QUERYING                                         -- 
-----------------------------------------------------------------------------------------------------------

-- Select table records as of a specific time in the past
SELECT * FROM my_table AT (TIMESTAMP => '2026-10-26 04:39:02.126 -0700'::timestamp_tz);

-- Select table records as they existed 300 seconds (5 minutes) ago
SELECT * FROM my_table AT(OFFSET => -60);

-- Select table records as they existed before a particular SQL statement
SELECT * FROM my_table BEFORE (STATEMENT => '01b4b1d4-3202-9972-0001-bc96000f4126');


-----------------------------------------------------------------------------------------------------------
--                                   TIME TRAVEL WHILE CLONING                                          -- 
-----------------------------------------------------------------------------------------------------------

-- Create a clone of my_table as it existed before a specific SQL statement
-- While the STATEMENT clause is used here, you can also use TIMESTAMP or OFFSET for cloning

CREATE TABLE my_restored_table CLONE my_table BEFORE (STATEMENT => '01b4b1d4-3202-9972-0001-bc96000f4126');

-- Query cloned table
SELECT * FROM my_restored_table;


-----------------------------------------------------------------------------------------------------------
--                         TIME TRAVEL AFTER ACCIDENTALLY DROPPING AN OBJECT                             -- 
-----------------------------------------------------------------------------------------------------------
-- While the UNDROP TABLE statement is used here, you can also UNDROP DATABASE and SCHEMA.

-- Drop the table
DROP TABLE my_table;

-- Query Dropped table
SELECT * FROM my_table;

-- Undrop the table
UNDROP TABLE my_table;



--------------------------------------------------------------------------------------------------------
--                    VERIFY TIME TRAVEL DURATION OF YOUR TABLE AND CHANGE AS NEEDED                   -- 
--------------------------------------------------------------------------------------------------------

-- CHECK YOUR TABLE TYPE AND TIME TRAVEL DURATION
SHOW TABLES LIKE '%my_table%';
SELECT "name", "database_name", "schema_name", "kind", "retention_time"  FROM TABLE(result_scan(last_query_id()));

-- CHANGE THE DEFAULT TIME TRAVEL DURATION
ALTER TABLE my_table SET DATA_RETENTION_TIME_IN_DAYS = 90;
