--                  Views LAB - Non-materialized views, Materialized views, Secure Views                 -- 
--               All commands/statements can be found via the link in the video description              --


CREATE OR REPLACE TABLE employee_details (
    employee_id INTEGER,
    employee_name VARCHAR,
    department VARCHAR,
    salary NUMBER(10,2)
);


INSERT INTO employee_details (employee_id, employee_name, department, salary) VALUES
    (10001, 'John Smith', 'Delivery', 60000.00),
    (10002, 'Emma Johnson', 'Delivery', 58000.00),
    (10003, 'Michael Lee', 'Delivery', 62000.00),
    (10004, 'Emily Brown', 'Delivery', 59000.00),
    (10005, 'Daniel Williams', 'Helpdesk', 40000.00),
    (10006, 'Olivia Jones', 'Helpdesk', 38000.00),
    (10007, 'Liam Garcia', 'Helpdesk', 42000.00),
    (10008, 'Sophia Martinez', 'Helpdesk', 41000.00),
    (10009, 'Noah Rodriguez', 'HR', 65000.00),
    (10010, 'Ava Hernandez', 'HR', 63000.00),
    (10011, 'Ethan Lopez', 'HR', 67000.00),
    (10012, 'Isabella Gonzales', 'HR', 64000.00),
    (10013, 'Mason Perez', 'Finance', 70000.00),
    (10014, 'Sophia Torres', 'Finance', 68000.00),
    (10015, 'Jacob Ramirez', 'Finance', 72000.00),
    (10016, 'Emma Flores', 'Finance', 69000.00),
    (10017, 'William Smith', 'Training', 55000.00),
    (10018, 'Charlotte Johnson', 'Training', 53000.00),
    (10019, 'James Lee', 'Training', 57000.00),
    (10020, 'Amelia Brown', 'Training', 54000.00),
    (10021, 'Alexander Wilson', 'Delivery', 61000.00),
    (10022, 'Mia Anderson', 'Delivery', 63000.00),
    (10023, 'Ethan Martinez', 'Delivery', 59000.00);

select * from employee_details;

CREATE OR REPLACE VIEW employee_details_restricted AS 
SELECT 
    employee_id, 
    employee_name, 
    department 
FROM 
    employee_details
WHERE department = 'Delivery';

select * from employee_details_restricted;



CREATE TABLE orders (
    order_id INTEGER,
    customer_id INTEGER,
    order_date DATE
);

CREATE TABLE order_items (
    item_id INTEGER,
    order_id INTEGER,
    product_name VARCHAR,
    quantity INTEGER,
    price_per_unit NUMBER(10,2)
);

INSERT INTO orders (order_id, customer_id, order_date) VALUES
    (1, 101, '2024-01-01'),
    (2, 102, '2024-01-02'),
    (3, 103, '2024-01-03');

INSERT INTO order_items (item_id, order_id, product_name, quantity, price_per_unit) VALUES
    (1, 1, 'Product A', 2, 15.00),
    (2, 1, 'Product B', 1, 25.00),
    (3, 2, 'Product C', 5, 10.00),
    (4, 3, 'Product D', 3, 20.00),
    (5, 3, 'Product E', 1, 50.00);


CREATE VIEW order_summary AS
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        COUNT(oi.item_id) AS total_items,
        SUM(oi.quantity * oi.price_per_unit) AS total_order_value
    FROM
        orders o
    JOIN
        order_items oi ON o.order_id = oi.order_id
    GROUP BY
        o.order_id, o.customer_id, o.order_date
    HAVING
        SUM(oi.quantity * oi.price_per_unit) >= 50.00;


SELECT customer_id, total_order_value 
FROM order_summary;




CREATE TABLE employee_salaries (
    employee_id INTEGER,
    salary_date DATE,
    employee_name VARCHAR,
    basic_salary NUMBER(10,2),
    allowances NUMBER(10,2),
    bonus NUMBER(10,2),
    tax NUMBER(10,2)
);

-- Sample data for a few employees
INSERT INTO employee_salaries (employee_id, salary_date, employee_name, basic_salary, allowances, bonus, tax) VALUES
    (1, '2024-01-01', 'John Doe', 4000.00, 500.00, 1000.00, 800.00),
    (2, '2024-01-01', 'Jane Smith', 4500.00, 600.00, 1200.00, 900.00),
    (3, '2024-01-01', 'Alice Johnson', 4200.00, 550.00, 1100.00, 850.00);
    -- Assume this pattern continues for all employees

CREATE or REPLACE MATERIALIZED VIEW yearly_employee_salaries_summary AS
    SELECT 
        employee_id,
        EXTRACT(YEAR FROM salary_date) AS year,
        employee_name,
        SUM(basic_salary + allowances + bonus - tax) AS total_salary
    FROM 
        employee_salaries
    GROUP BY
        employee_id,
        year,
        employee_name;

SELECT * FROM yearly_employee_salaries_summary;




CREATE OR REPLACE SECURE VIEW employee_details_delivery AS 
SELECT 
    employee_id, 
    employee_name, 
    department,
    salary
FROM 
    employee_details
WHERE department = 'Delivery';



CREATE OR REPLACE SECURE MATERIALIZED VIEW employee_details_delivery_m AS 
SELECT 
    employee_id, 
    employee_name, 
    department,
    salary
FROM 
    employee_details
WHERE department = 'Delivery';



SELECT GET_DDL('VIEW', 'employee_details_delivery');
-- Works on ACCOUNTADMIN role, but does not work if view is secure and user has SELECT-only access.








CREATE OR REPLACE SECURE VIEW employee_details_delivery AS 
SELECT 
    employee_id, 
    employee_name, 
    department,
    salary
FROM 
    employee_details
WHERE department = 'Delivery';


SELECT *
FROM employee_details_delivery
WHERE department = 'HR' AND salary > 60000;

SELECT *
FROM employee_details_delivery
WHERE 1/ iff(department = 'HR' AND salary > 60000, 0, 1) = 0;

SELECT *
FROM employee_details_delivery
WHERE 1/ 0 = 0;
