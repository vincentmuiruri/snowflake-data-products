-----Follow the link in the description for the SQLs used in this lab ------

---------------------------------------------------------------------------
---------------- Setting Up Foundational Objects for the Lab---------------
---------------------------------------------------------------------------

--Create Database and Schema
CREATE OR REPLACE DATABASE order_db;
CREATE OR REPLACE SCHEMA order_db.order_schema;

-- Create Tables
USE SCHEMA order_db.order_schema;

CREATE or replace TABLE order_raw (
    order_id INT,
    order_date DATE,
    cust_fname VARCHAR(50),
    cust_lname VARCHAR(50),
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    discounts DECIMAL(10, 2)
);


CREATE OR REPLACE STAGE order_raw_ext_stg
  URL='s3://s3explore/'
  -- CREDENTIALS=(AWS_KEY_ID='your_AWS_KEY_ID' AWS_SECRET_KEY='your_AWS_SECRET_KEY');  


---------------------------------------------------------------------------
----------------------------- SNOWPIPE MAIN LAB----------------------------
---------------------------------------------------------------------------

CREATE OR REPLACE PIPE order_raw_pipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO order_raw
  FROM @order_raw_ext_stg
  FILE_FORMAT = (TYPE = 'CSV');

SHOW PIPES;


select * from order_raw;