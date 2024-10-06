create database assignment;
use assignment;
create table employee(emp_id int,first_name varchar(20),last_name varchar(20),salary int,Home_town varchar(20));
INSERT INTO employee (emp_id, first_name, last_name, salary, Home_town) VALUES
(1, 'Alice', 'Smith', 60000, 'New York'),
(2, 'Bob', 'Johnson', 55000, 'Los Angeles'),
(3, 'Charlie', 'Brown', 70000, 'Chicago'),
(4, 'Diana', 'Wilson', 65000, 'Houston'),
(5, 'Ethan', 'Davis', 72000, 'Phoenix');
1)Find all employees whose first names start with a vowel and whose last names end with a consonant.
select * from employee where lower(substring(first_name,1,1)) in ('a','e','i','o','u') and lower(substring(last_name,LENGTH(last_name),1)) not in ('a','e','i','o','u');
2)For each department, display the total salary expenditure, the average salary, and the highest salary. Use window functions to calculate the total, average, 
and max salary, but show each result for all employees in that department.
SELECT 
    department,
    employee_id,
    salary,
    SUM(salary) OVER (PARTITION BY department) AS total_salary_expenditure,
    AVG(salary) OVER (PARTITION BY department) AS average_salary,
    MAX(salary) OVER (PARTITION BY department) AS highest_salary
FROM employee;
3)Write a query that fetches the following:
All employees, their department name, their manager’s name (if they have one), and their salary.
You will need to:
Join employees with their department.
Perform a self-join to fetch the manager’s name.
SELECT 
    e1.emp_id,
    e1.first_name AS employee_name,
    d.department_name,
    e2.first_name AS manager_name,
    e1.salary
FROM 
    employee e1
JOIN 
    departments d ON e1.department_id = d.department_id
LEFT JOIN 
    employee e2 ON e1.manager_id = e2.emp_id;  -- Self join to get manager's name
4)Create a query using a recursive CTE to list all employees and their respective reporting chains (i.e., list the manager’s manager and so on).
WITH RECURSIVE EmployeeChain AS (
    SELECT 
        emp_id,
        first_name,
        manager_id
    FROM 
        employee
    WHERE 
        manager_id IS NOT NULL  -- Start with employees having a manager

    UNION ALL

    SELECT 
        e.emp_id,
        e.first_name,
        e.manager_id
    FROM 
        employee e
    INNER JOIN 
        EmployeeChain ec ON e.emp_id = ec.manager_id  -- Recursive join to fetch the manager
)

SELECT 
    emp_id,
    first_name,
    manager_id
FROM 
    EmployeeChain;
5)Write a query to fetch the details of employees earning above a certain salary threshold. Investigate the performance of this query and suggest improvements, including the use of indexes
CREATE INDEX idx_salary ON employee(salary);
6)6)ou need to create a detailed sales report. First, create a temporary table to store interim sales data for each product, including total sales, average sales per customer, and the top salesperson for each product.
Hint:
Use temporary tables and insert data from subqueries. 
CREATE TEMPORARY TABLE temp_sales_report (
    product_id INT,
    total_sales DECIMAL(10, 2),
    average_sales_per_customer DECIMAL(10, 2),
    top_salesperson VARCHAR(50)
);
INSERT INTO temp_sales_report (product_id, total_sales, average_sales_per_customer, top_salesperson)
SELECT 
    p.product_id,
    SUM(s.amount) AS total_sales,
    AVG(s.amount) AS average_sales_per_customer,
    (SELECT 
         e.first_name
     FROM 
         employee e
     JOIN 
         sales sa ON e.emp_id = sa.salesperson_id
     WHERE 
         sa.product_id = p.product_id
     ORDER BY 
         sa.amount DESC
     LIMIT 1) AS top_salesperson
FROM 
    products p
JOIN 
    sales s ON p.product_id = s.product_id
GROUP BY 
    p.product_id;

