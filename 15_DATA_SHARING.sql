-----------------------------------------------------------------------------------------------------------
--                                    SOWFLAKE SECURE DATA SHARING LAB                                   -- 
--               All commands/statements can be found via the link in the Video Description              --
-----------------------------------------------------------------------------------------------------------

-- Create a database & Schema
CREATE DATABASE product_db;
CREATE SCHEMA product_db.core_schema;

-- Create a database & Schema
CREATE OR REPLACE DATABASE product_db;
CREATE OR REPLACE SCHEMA product_db.core_schema;

-- Switch to the newly created database and schema
USE DATABASE product_db;
USE SCHEMA product_db.core_schema;

-- Create Products table
CREATE OR REPLACE TABLE products (
    product_id INTEGER,
    product_name VARCHAR(100),
    category VARCHAR(50),
    color VARCHAR(50),
    weight DECIMAL(10, 2)
);

-- Create Customer table
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone_number VARCHAR(20)
);

-- Create Orders tableGLOBAL_WEATHER_DB
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10, 2)
);

-- Insert data into Products table
INSERT INTO products (product_id, product_name, category, color, weight)
VALUES
    (1, 'Laptop', 'Electronics', 'Silver', 1.8),
    (2, 'T-shirt', 'Clothing', 'Red', 0.2),
    (3, 'Kitchen Mixer', 'Home & Kitchen', 'White', 3.5),
    (4, 'Headphones', 'Electronics', 'Black', 0.3),
    (5, 'Jeans', 'Clothing', 'Blue', 0.5);

    
---------------------------------------------------------------------------------------------------------------------------------
------------------------------- Please execute the commands above to create some objects for practice ---------------------------
---------------------------------------------------------------------------------------------------------------------------------


-- Set role to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Create or replace a share
CREATE OR REPLACE SHARE products_share;

-- Grant USAGE permissions on database and schema
GRANT USAGE ON DATABASE product_db TO SHARE products_share;
GRANT USAGE ON SCHEMA product_db.core_schema TO SHARE products_share;

-- Grant SELECT permissions on database and schema
GRANT SELECT ON TABLE product_db.core_schema.products TO SHARE products_share;

-- Manage consumer accounts
ALTER SHARE products_share ADD ACCOUNTS = ORSRQCR.UBB81440;    -- Multiple accounts can be added using commas
-- ALTER SHARE products_share REMOVE ACCOUNTS = YYJFVCA.GV88781; -- To stop sharing with an account

ALTER SHARE products_share ADD ACCOUNTS = CW81583

Consumer:

-- Create a database & Schema
CREATE OR REPLACE DATABASE sales_db;
CREATE OR REPLACE SCHEMA sales_db.sales_schema;

-- Switch to the newly created database and schema
USE DATABASE sales_db;
USE SCHEMA sales_db.sales_schema;

-- Create Sales table
CREATE TABLE sales (
    sale_id INTEGER,
    product_id INTEGER,
    sale_date DATE,
    sale_quantity INTEGER,
    total_sale_amount DECIMAL(10, 2)
);

-- Insert data into Sales table
INSERT INTO sales (sale_id, product_id, sale_date, sale_quantity, total_sale_amount)
VALUES
    (1, 1, '2024-06-15', 2, 1999.98),
    (2, 2, '2024-06-15', 3, 59.97),
    (3, 1, '2024-06-16', 1, 999.99),
    (4, 3, '2024-06-16', 2, 699.98),
    (5, 4, '2024-06-17', 1, 149.99);

    
---------------------------------------------------------------------------------------------------------------------------------
------------------------------- Please execute the commands above to create some objects for practice ---------------------------
---------------------------------------------------------------------------------------------------------------------------------


-- Switch to Account Admin Role
USE ROLE ACCOUNTADMIN;

-- Show existing shares
SHOW SHARES;

-- Create database from share and set context
CREATE DATABASE products_db_shr FROM SHARE pffzvfj.ge15565.products_share;


-- Select and display data from products table
USE DATABASE products_db_shr;
USE SCHEMA core_schema;
SELECT * FROM products;

-- Joining products table from shared database and sales from consumer's own databse
SELECT
    s.sale_id,
    p.product_name,
    p.category,
    p.color,
    p.weight,
    s.sale_date,
    s.sale_quantity,
    s.total_sale_amount
FROM
    sales_db.sales_schema.sales s
JOIN
    products_db_shr.core_schema.products p ON s.product_id = p.product_id;
