CREATE DATABASE BankingAnalysis;
USE BankingAnalysis;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    gender CHAR(1), 
    dob DATE,
    city VARCHAR(100),
    joined_on DATE
);


CREATE TABLE branches (
    branch_id INT PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(100)
);

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(12, 2),
    branch_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(10), -- 'credit' or 'debit'
    amount DECIMAL(10, 2),
    transaction_date DATETIME,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


INSERT INTO customers (customer_id, name, gender, dob, city, joined_on) VALUES
(1, 'Ayesha Khan', 'F', '1990-03-21', 'Mumbai', '2020-01-10'),
(2, 'Ravi Sharma', 'M', '1985-07-15', 'Delhi', '2018-06-25'),
(3, 'Meena Joshi', 'F', '1992-11-02', 'Pune', '2019-09-10'),
(4, 'Karan Mehta', 'M', '1998-05-30', 'Nashik', '2021-03-12'),
(5, 'Sneha Patil', 'F', '1995-08-18', 'Nagpur', '2022-01-01');


INSERT INTO branches (branch_id, branch_name, city) VALUES
(101, 'Mumbai Main', 'Mumbai'),
(102, 'Delhi South', 'Delhi'),
(103, 'Pune Central', 'Pune'),
(104, 'Nashik North', 'Nashik'),
(105, 'Nagpur East', 'Nagpur');


INSERT INTO accounts (account_id, customer_id, account_type, balance, branch_id) VALUES
(1001, 1, 'Savings', 55000.00, 101),
(1002, 2, 'Current', 25000.00, 102),
(1003, 3, 'Savings', 70000.00, 103),
(1004, 4, 'Current', 32000.00, 104),
(1005, 5, 'Savings', 15000.00, 105);


INSERT INTO transactions (transaction_id, account_id, transaction_type, amount, transaction_date) VALUES
(1, 1001, 'credit', 10000.00, '2024-06-01 10:30:00'),
(2, 1001, 'debit', 5000.00, '2024-06-02 14:00:00'),
(3, 1002, 'credit', 15000.00, '2024-06-01 11:00:00'),
(4, 1002, 'debit', 10000.00, '2024-06-03 09:00:00'),
(5, 1003, 'debit', 20000.00, '2024-06-01 13:45:00'),
(6, 1003, 'credit', 5000.00, '2024-06-04 16:30:00'),
(7, 1004, 'credit', 25000.00, '2024-06-05 17:00:00'),
(8, 1005, 'debit', 10000.00, '2024-06-02 12:15:00'),
(9, 1005, 'credit', 2000.00, '2024-06-06 08:30:00'),
(10, 1004, 'debit', 5000.00, '2024-06-07 10:00:00');


SELECT
    DATE(transaction_date) AS txn_day,
    SUM(CASE WHEN transaction_type = 'debit' THEN amount ELSE 0 END) AS total_debit,
    SUM(CASE WHEN transaction_type = 'credit' THEN amount ELSE 0 END) AS total_credit
FROM transactions
GROUP BY DATE(transaction_date)
ORDER BY txn_day;


SELECT
    t.transaction_id,
    c.name AS customer_name,
    a.account_id,
    t.amount AS debit_amount,
    t.transaction_date
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.transaction_type = 'debit'
  AND t.amount > 10000
ORDER BY t.amount DESC;



SELECT
    c.customer_id,
    c.name AS customer_name,
    SUM(CASE WHEN t.transaction_type = 'credit' THEN t.amount ELSE 0 END) AS total_credit,
    SUM(CASE WHEN t.transaction_type = 'debit' THEN t.amount ELSE 0 END) AS total_debit,
    (SUM(CASE WHEN t.transaction_type = 'credit' THEN t.amount ELSE 0 END) -
     SUM(CASE WHEN t.transaction_type = 'debit' THEN t.amount ELSE 0 END)) AS net_value
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.name
ORDER BY net_value DESC;



WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.name AS customer_name,
        SUM(t.amount) AS total_transaction_value
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    JOIN transactions t ON a.account_id = t.account_id
    GROUP BY c.customer_id, c.name
)
SELECT *,
       RANK() OVER (ORDER BY total_transaction_value DESC) AS rank_by_value
FROM customer_totals;


