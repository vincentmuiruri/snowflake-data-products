-----------------------------------------------------------------------------------------------------------
--                                         SNOWFLAKE CLONING LAB                                         -- 
--               All commands/statements can be found via the link in the Video Description              --
-----------------------------------------------------------------------------------------------------------

-- Create a database & Schema
CREATE DATABASE IF NOT EXISTS demo_db;
CREATE SCHEMA IF NOT EXISTS demo_db.demo_schema;
CREATE SCHEMA IF NOT EXISTS demo_db.another_demo_schema;

-- Switch to the newly created database and schema
USE DATABASE demo_db;
USE SCHEMA demo_db.demo_schema;

-- Create Table
CREATE TABLE customers (
    cust_id INT,
    name VARCHAR(255),
    city VARCHAR(255)
);

-- Create Table
CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    order_amt DECIMAL(10, 2)
);

-- Insert 5 new records into the customers table
INSERT INTO customers (cust_id, name, city) VALUES
(1, 'John Doe', 'New York'),
(2, 'Jane Smith', 'Los Angeles'),
(3, 'Michael Johnson', 'Chicago'),
(4, 'Emily Davis', 'New York'),
(5, 'David Brown', 'San Francisco');

-- Retrieve the current timestamp, so that we can demo cloning with Time Travel later
SELECT CURRENT_TIMESTAMP();
--2026-10-26 04:54:30.583 -0700

-- Create View for New York customers
CREATE VIEW customers_new_york AS
SELECT * FROM customers WHERE city = 'New York';

-- Create Named Internal Stage
CREATE STAGE my_internal_stg;

-- Create Named External Stage
CREATE STAGE my_s3_external_stg
  URL='s3://s3explore/'
  CREDENTIALS=(AWS_KEY_ID='AKIA5U56BPGP3TLNXQ4S' AWS_SECRET_KEY='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');




  
-----------------------------------------------------------------------------------------------------------






-- Clone the entire Database and all supported child objects
CREATE DATABASE IF NOT EXISTS demo_db_clone CLONE demo_db;
DROP DATABASE demo_db_clone;

-- Clone the entire schema and all supported child objects
USE DATABASE demo_db;
CREATE SCHEMA IF NOT EXISTS demo_schema_clone CLONE demo_schema;
DROP SCHEMA demo_schema_clone;

-- Clone an individual object (table in this example)
USE SCHEMA demo_db.demo_schema;
CREATE TABLE customers_clone CLONE customers;

-- Select from both tables to see they have the same records
SELECT * FROM customers;
SELECT * FROM customers_clone;

-- Both tables can be independently managed (inserted, updated, or deleted) without causing any conflicts
INSERT INTO customers (cust_id, name, city) VALUES
(6, 'Alice Johnson', 'Boston'),
(7, 'Tom Brown', 'Miami'),
(8, 'Sarah Wilson', 'Seattle');

-- Select from both tables to see the above 3 records only affected the customers table
SELECT * FROM customers;
SELECT * FROM customers_clone;

-- Insert/update/delete records in customers_clone
INSERT INTO customers_clone (cust_id, name, city) VALUES
(10, 'Robert Green', 'Denver');

-- Select from both tables to see the above 1 record only affected the customers_clone table
SELECT * FROM customers;
SELECT CURRENT_TIMESTAMP();
SELECT * FROM customers_clone;

-- Time Travel and Cloning Together: Clone an object as it existed at a specific timestamp in the past
-- I have demonstrated with tables; you can use Time Travel to clone databases and schemas
CREATE TABLE customers_clone_after_first_inserts CLONE customers
     BEFORE (TIMESTAMP => '2026-10-26 05:03:02.290 -0700'::timestamp_tz);

-- Fun fact: you can indeed clone an already cloned object!
CREATE TABLE customers_clone2 CLONE customers_clone;


SELECT CURRENT_REGION();