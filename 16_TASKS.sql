------------------- Follow the link in the description for the SQLs used in this lab -------------------

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

CREATE OR REPLACE TABLE order_analytics (
    order_id INT,
    order_date DATE,
    cust_name VARCHAR(100),
    product_id INT,
    total_price DECIMAL(10, 2)
);

CREATE OR REPLACE NOTIFICATION INTEGRATION my_email_integration
  TYPE=EMAIL
  ENABLED=TRUE
  ALLOWED_RECIPIENTS=('vmbira@yayaresources.com');
  

CREATE OR REPLACE STAGE order_raw_ext_stg
  URL='s3://s3explore/'
  CREDENTIALS=(AWS_KEY_ID='your_AWS_KEY_ID' AWS_SECRET_KEY='your_AWS_SECRET_KEY');
  
--Create Steam
CREATE OR REPLACE STREAM order_raw_stream ON TABLE order_raw;


---------------------------------------------------------------------------
-------------------------- Standalone TASK setup --------------------------
---------------------------------------------------------------------------


CREATE OR REPLACE TASK load_order_analytics
  WAREHOUSE = compute_wh
  SCHEDULE = 'USING CRON 0/5 * * * * UTC'        --- or SCHEDULE = '5 MINUTE'
  AS
  INSERT INTO order_analytics
  SELECT 
      order_id,
      order_date,
      CONCAT(cust_fname, ' ', cust_lname) AS cust_name,
      product_id,
      (quantity * unit_price) - discounts AS total_price
  FROM order_raw_stream;



ALTER TASK load_order_analytics RESUME;


---------------------------------------------------------------------------
----------------------Multiple TASKs Chained Together----------------------
---------------------------------------------------------------------------

-- Task 1: copy_data
CREATE OR REPLACE TASK copy_data
  WAREHOUSE = compute_wh
  SCHEDULE = '5 MINUTE'
  AS
  COPY INTO order_raw
  FROM @order_raw_ext_stg
  FILE_FORMAT = (TYPE = 'CSV');
  

-- Task 2: transform_data
CREATE OR REPLACE TASK transform_data
  WAREHOUSE = compute_wh
  AFTER copy_data 
  WHEN SYSTEM$STREAM_HAS_DATA('order_raw_stream')
  AS
  INSERT INTO order_analytics
  SELECT 
      order_id,
      order_date,
      CONCAT(cust_fname, ' ', cust_lname) AS cust_name,
      product_id,
      (quantity * unit_price) - discounts AS total_price
  FROM order_raw_stream;


-- Task 3: send_email_report
CREATE OR REPLACE TASK send_email_report
  WAREHOUSE = COMPUTE_WH
  AFTER transform_data
  AS
  BEGIN
    CALL SYSTEM$SEND_EMAIL(
      'my_email_integration',
      'vmbira@yayaresources.com',
      'Regular ORDER Data Processing Report',
      'The Regular ORDER data processing is complete.'
    );
  END;


ALTER TASK send_email_report RESUME;
ALTER TASK transform_data RESUME;
ALTER TASK copy_data RESUME;


select * from order_analytics;






---------------------------------------------------------------------------
--------------------------External Table Approach--------------------------
---------------------------------------------------------------------------



CREATE OR REPLACE EXTERNAL TABLE order_raw_ext_table (
    order_id INT AS (VALUE:c1::INT),
    order_date DATE AS (VALUE:c2::DATE),
    cust_fname VARCHAR(50) AS (VALUE:c3::VARCHAR(50)),
    cust_lname VARCHAR(50) AS (VALUE:c4::VARCHAR(50)),
    product_id INT AS (VALUE:c5::INT),
    quantity INT AS (VALUE:c6::INT),
    unit_price DECIMAL(10, 2) AS (VALUE:c7::DECIMAL(10, 2)),
    discounts DECIMAL(10, 2) AS (VALUE:c8::DECIMAL(10, 2))
)
WITH LOCATION = @order_raw_ext_stg
AUTO_REFRESH = TRUE
FILE_FORMAT = (TYPE = 'CSV');

-- Verify that the external table is created and accessible
select * from order_raw_ext_table;

-- Display all external tables in the current database
SHOW EXTERNAL TABLES; 

-- Instructions for setting up event notifications in AWS S3:
-- 1. Copy the notification_channel URL from the output of SHOW EXTERNAL TABLES.
-- 2. Log in to the AWS Console and navigate to your S3 Bucket properties.
-- 3. Go to the Event Notifications section and click Create event notification.
-- 4. Name the event as desired.
-- 5. For Event types, select ObjectCreated (All) and ObjectRemoved.
-- 6. For Destination, select 'SQS queue'. Then select 'Enter SQS queue ARN' and paste the URL you copied earlier into the 'SQS queue' field.
-- 7. Save the changes.


-- To activate AUTO_REFRESH, perform a manual refresh once. Subsequent refreshes will be automatic.
ALTER EXTERNAL TABLE order_raw_ext_table REFRESH;


--Create Steam
CREATE OR REPLACE STREAM order_raw_ext_table_stream 
ON EXTERNAL TABLE order_raw_ext_table 
INSERT_ONLY = TRUE;
ORDER_DB.ORDER_SCHEMA.TRANSFORM_DATAORDER_DB.ORDER_SCHEMA.TRANSFORM_DATA

-- Task 1: transform_data
CREATE OR REPLACE TASK transform_data_using_ext_tbl
  WAREHOUSE = compute_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('order_raw_ext_table_stream')
  AS
  INSERT INTO order_analytics
  SELECT 
      order_id,
      order_date,
      CONCAT(cust_fname, ' ', cust_lname) AS cust_name,
      product_id,
      (quantity * unit_price) - discounts AS total_price
  FROM order_raw_ext_table_stream;


-- Task 2: send_email_report
CREATE OR REPLACE TASK send_email_report_ext_tbl
  WAREHOUSE = COMPUTE_WH
  AFTER transform_data_using_ext_tbl
  AS
  BEGIN
    CALL SYSTEM$SEND_EMAIL(
      'my_email_integration',
      'tuftech007@outlook.com',
      'Regular ORDER Data Processing Report',
      'The Regular ORDER data processing is complete.'
    );
  END;



ALTER TASK transform_data_using_ext_tbl RESUME;
ALTER TASK send_email_report_ext_tbl RESUME;
