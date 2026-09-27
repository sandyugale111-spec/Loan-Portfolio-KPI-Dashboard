create database BankLoan_project;

Use BankLoan_project;

select database();

show tables;

SELECT COUNT(*) AS total_rows
FROM finance_1;

SELECT COUNT(*) AS total_rows
FROM finance_2;

Drop table finance_1;
Drop table finance_2;

SHOW VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = 1;

USE bankloan_project;

CREATE TABLE finance_1 (
    id INT,
    member_id INT,
    loan_amnt DECIMAL(10,2),
    funded_amnt DECIMAL(10,2),
    funded_amnt_inv DECIMAL(10,2),
    term VARCHAR(50),
    int_rate VARCHAR(50),
    installment DECIMAL(10,2),
    grade VARCHAR(10),
    sub_grade VARCHAR(10),
    emp_title TEXT,
    emp_length VARCHAR(50),
    home_ownership VARCHAR(50),
    annual_inc DECIMAL(15,2),
    verification_status VARCHAR(100),
    issue_d VARCHAR(50),
    loan_status VARCHAR(100),
    pymnt_plan VARCHAR(20),
    `desc` TEXT,
    purpose VARCHAR(100),
    title TEXT,
    zip_code VARCHAR(20),
    addr_state VARCHAR(10),
    dti DECIMAL(10,2)
);

SHOW VARIABLES LIKE 'local_infile';

USE bankloan_project;

SELECT DATABASE();

LOAD DATA LOCAL INFILE 'G:/ExcelR_BA Course/Project/Bank Analytics Datasets/Bank Analytics/Finance_1 (2) (1).csv'
INTO TABLE finance_1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_rows
FROM finance_1;

CREATE TABLE finance_2 (
    id INT,
    delinq_2yrs INT,
    earliest_cr_line VARCHAR(50),
    inq_last_6mths INT,
    mths_since_last_delinq VARCHAR(50),
    mths_since_last_record VARCHAR(50),
    open_acc INT,
    pub_rec INT,
    revol_bal INT,
    revol_util VARCHAR(50),
    total_acc INT,
    initial_list_status VARCHAR(20),
    out_prncp DECIMAL(15,2),
    out_prncp_inv DECIMAL(15,2),
    total_pymnt DECIMAL(15,2),
    total_pymnt_inv DECIMAL(15,2),
    total_rec_prncp DECIMAL(15,2),
    total_rec_int DECIMAL(15,2),
    total_rec_late_fee DECIMAL(15,2),
    recoveries DECIMAL(15,2),
    collection_recovery_fee DECIMAL(15,2),
    last_pymnt_d VARCHAR(50),
    last_pymnt_amnt DECIMAL(15,2),
    last_credit_pull_d VARCHAR(50),
    collections_12_mths_ex_med INT
);

SHOW TABLES;

LOAD DATA LOCAL INFILE 'G:/ExcelR_BA Course/Project/Bank Analytics Datasets/Bank Analytics/Finance_2 (2) (1).csv'
INTO TABLE finance_2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_rows
FROM finance_2;

SELECT COUNT(*) AS unmatched_ids
FROM finance_1 f1
LEFT JOIN finance_2 f2
    ON f1.id = f2.id
WHERE f2.id IS NULL;

SELECT COUNT(*) AS unmatched_ids
FROM finance_2 f2
LEFT JOIN finance_1 f1
    ON f2.id = f1.id
WHERE f1.id IS NULL;

SELECT
    f1.id,
    f1.loan_amnt,
    f1.term,
    f1.int_rate,
    f1.grade,
    f2.delinq_2yrs,
    f2.open_acc,
    f2.revol_bal,
    f2.total_pymnt,
    f2.last_pymnt_amnt
FROM finance_1 f1
JOIN finance_2 f2
    ON f1.id = f2.id
LIMIT 10;


/* 1st Query:
Year wise loan amount Stats
*/

SELECT 
    YEAR(STR_TO_DATE(issue_d, '%b-%Y')) AS year,
    SUM(loan_amnt) AS total_loan_amount
FROM finance_1
GROUP BY YEAR(STR_TO_DATE(issue_d, '%b-%Y'))
ORDER BY year;

SELECT
    issue_d,
    RIGHT(TRIM(issue_d), 2) AS year_2digit
FROM finance_1
LIMIT 20;

SELECT
    CONCAT('20', RIGHT(TRIM(issue_d), 2)) AS year,
    SUM(loan_amnt) AS total_loan_amount
FROM finance_1
GROUP BY CONCAT('20', RIGHT(TRIM(issue_d), 2))
ORDER BY year;


/*2nd Query:
Grade and sub grade wise revol_bal
*/

SELECT
    f1.grade,
    f1.sub_grade,
    SUM(f2.revol_bal) AS total_revol_bal
FROM finance_1 f1
JOIN finance_2 f2
    ON f1.id = f2.id
GROUP BY
    f1.grade,
    f1.sub_grade
ORDER BY
    f1.grade,
    f1.sub_grade;
    
    
/*3rd Query:
Total Payment for Verified Status Vs Total Payment for Non Verified Status
*/

SELECT
    CASE
        WHEN f1.verification_status = 'Verified'
            THEN 'Verified'
        ELSE 'Non-Verified'
    END AS verification_group,
    SUM(f2.total_pymnt) AS total_payment
FROM finance_1 f1
JOIN finance_2 f2
    ON f1.id = f2.id
GROUP BY
    CASE
        WHEN f1.verification_status = 'Verified'
            THEN 'Verified'
        ELSE 'Non-Verified'
    END;
    
    
/*4th Query:
Total Payment for Verified Status Vs Total Payment for Non Verified Status
*/

SELECT
    f1.addr_state AS state,
    f2.last_credit_pull_d,
    f1.loan_status,
    COUNT(*) AS total_loans
FROM finance_1 f1
JOIN finance_2 f2
    ON f1.id = f2.id
GROUP BY
    f1.addr_state,
    f2.last_credit_pull_d,
    f1.loan_status
ORDER BY
    f1.addr_state,
    f2.last_credit_pull_d,
    f1.loan_status;
    

/*5th Query:
Home ownership Vs last payment date stats
*/

SELECT
    f1.home_ownership,
    f2.last_pymnt_d,
    COUNT(*) AS total_loans
FROM finance_1 f1
JOIN finance_2 f2
    ON f1.id = f2.id
GROUP BY
    f1.home_ownership,
    f2.last_pymnt_d
ORDER BY
    f1.home_ownership,
    f2.last_pymnt_d;

SELECT
    f1.home_ownership,
    YEAR(STR_TO_DATE(f2.last_pymnt_d, '%b-%y')) AS payment_year,
    COUNT(*) AS total_loans,
    SUM(f2.total_pymnt) AS total_payment
FROM finance_1 f1
JOIN finance_2 f2
    ON f1.id = f2.id
WHERE f2.last_pymnt_d IS NOT NULL
GROUP BY
    f1.home_ownership,
    YEAR(STR_TO_DATE(f2.last_pymnt_d, '%b-%y'))
ORDER BY
    payment_year,
    f1.home_ownership;
    
