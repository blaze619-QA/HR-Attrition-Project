--HR Employee Attrition Analysis
-- Create HR Employee Attrition table

create table hr_employee_data (
  age int,
  attrition varchar(20),
  businesstravel varchar(20),
  dailyrate int,
  department varchar(50),
  distancefromhome int,
  education int,
  educationfield varchar(50),
  employeecount int,
  employeenumber int,
  environmentsatisfaction int,
  gender varchar(10),
  hourlyrate decimal(10, 2),
  jobinvolvement int,
  joblevel int,
  jobrole varchar(50),
  jobsatisfaction int,
  maritalstatus varchar(20),
  monthlyincome decimal(10, 2),
  monthlyrate decimal(10, 2),
  numcompaniesworked int,
  over18 varchar(10),
  overtime varchar(10),
  percentsalaryhike int,
  performancerating int,
  relationshipsatisfaction int,
  standardhours int,
  stockoptionlevel int,
  totalworkingyears int,
  trainingtimeslastyear int,
  worklifebalance int,
  yearsatcompany int,
  yearsincurrentrole int,
  yearssincelastpromotion int,
  yearswithcurrmanager int
);

-- Confirm the table is created & view the data
SELECT * FROM hr_employee_data;

-- Basic Data Exploration

-- How many employees are in the dataset?
SELECT COUNT(*) AS total_employees
FROM hr_employee_data;

-- How many employees have left the company (attrition = 'Yes')?
SELECT COUNT(*) AS left_company
FROM hr_employee_data
WHERE attrition = 'Yes';

-- What are the unique departments in the company?
SELECT DISTINCT department
FROM hr_employee_data;

-- List all female employees who work overtime.
SELECT 
  employeenumber,
  age,
  department,
  jobrole
FROM hr_employee_data
WHERE gender = 'Female' AND overtime = 'Yes';

-- Show employees earning more than $10,000 per month.
SELECT 
  employeenumber,
  jobrole,
  department,
  monthlyincome
FROM hr_employee_data
WHERE monthlyincome > 10000
ORDER BY monthlyincome DESC;

-- What is the attriion count by department?
SELECT
  department,
  COUNT(*) AS total,
  SUM(CASE
        WHEN attrition = 'Yes' THEN 1 ELSE 0
      END) AS left_company
FROM hr_employee_data
GROUP BY department
ORDER BY left_company;

-- What is the average monthly income by job role?
SELECT
  jobrole,
  ROUND(AVG(monthlyincome), 2) AS avg_income,
  COUNT(*) AS headcount
FROM hr_employee_data
GROUP BY jobrole
ORDER BY avg_income DESC;

-- What is the attrition rate (%) by gender?
SELECT
  gender,
  COUNT(*) AS total,
  SUM(CASE
       WHEN attrition = 'Yes' THEN 1 ELSE 0
       END ) AS attrition_count,
  ROUND(100.0 * SUM(CASE
                    WHEN attrition = 'Yes' THEN 1 ELSE 0
       END ) / COUNT(*), 2) AS attrition_rate_pct
FROM hr_employee_data
GROUP BY gender;

--Which job roles have an average satisfaction below 2.5?
SELECT 
  jobrole,
  ROUND(AVG(jobsatisfaction), 2) AS avg_satisfaction
FROM hr_employee_data
GROUP BY jobrole
HAVING AVG(jobsatisfaction) < 2.5
ORDER BY avg_satisfaction ASC;

--How many employees are in each marital status category, broken down by attrition?
SELECT
  maritalstatus,
  attrition,
  COUNT(*) AS count
FROM hr_employee_data
GROUP BY maritalstatus, attrition
ORDER BY maritalstatus, attrition;

--What is the average work-life balance for overtime vs non-overtime employees?
SELECT
overtime,
ROUND(AVG(worklifebalance), 2) AS avg_worklife_b,
ROUND(AVG(jobsatisfaction), 2) AS avg_job_s
FROM hr_employee_data
GROUP BY overtime;

--Find employees earning below the average salary for their job role.
SELECT
e.employeenumber, e.jobrole, e.monthlyincome, ra.avg_income
FROM hr_employee_data AS e
JOIN (
  SELECT jobrole, ROUND(AVG(monthlyincome), 2) AS avg_income
  FROM hr_employee_data
  GROUP BY jobrole
) AS ra ON e.jobrole = ra.jobrole
WHERE e.monthlyincome < ra.avg_income
ORDER BY e.jobrole, e.monthlyincome;

--Classify employees by income bracket using CASE.
SELECT 
employeenumber, monthlyincome,
  CASE
    WHEN monthlyincome < 3000 THEN 'LOW'
    WHEN monthlyincome BETWEEN 3000 AND 7000 THEN 'medium'
    WHEN monthlyincome BETWEEN 7001 AND 12000 THEN 'high'
    ELSE 'very high'
  END AS income_bracket
FROM hr_employee_data
ORDER BY monthlyincome DESC,

--What % of employees in each income bracket left the company?
SELECT  income_bracket, 
        COUNT(*) AS total,
        SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
        ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2) AS attrition_pct
FROM (
    SELECT attrition,
            CASE
    WHEN monthlyincome < 3000 THEN 'LOW'
    WHEN monthlyincome BETWEEN 3000 AND 7000 THEN 'medium'
    WHEN monthlyincome BETWEEN 7001 AND 12000 THEN 'high'
    ELSE 'very high'
  END AS income_bracket
FROM hr_employee_data
)
GROUP BY income_bracket
ORDER BY attrition_pct DESC;

--Rank job roles by attrition rate using a subquery.
SELECT jobrole, total, left_count,
        ROUND(100.0 * left_count / total, 2) AS attrition_pct
FROM (
       SELECT jobrole,
               COUNT(*) AS total,
               SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count
        FROM hr_employee_data
        GROUP BY jobrole
)
ORDER BY attrition_pct DESC;

-- Find the top 5 departments + job roles with the longest avg tenure.
SELECT department, jobrole,
        ROUND(AVG(yearsatcompany), 1) AS avg_years,
        COUNT(*) AS headcount
FROM hr_employee_data
GROUP BY department, jobrole
ORDER BY avg_years DESC
LIMIT 5;

--Do employees who travel frequently have higher attrition?
SELECT businesstravel,
        COUNT(*) AS TOTAL,
        SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS left_count,
        ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2) AS attrition_rate
FROM hr_employee_data
GROUP BY businesstravel
ORDER BY attrition_rate DESC;

--Which education field has the most attrition?
SELECT  educationfield,
        COUNT(*) AS total,
        SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
        ROUND(100.0 * SUM(CASE WHEN attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2) AS rate
FROM hr_employee_data
GROUP BY educationfield
ORDER BY rate DESC;

--Find employees who have never been promoted and are still at the company.
SELECT employeenumber, jobrole, yearsatcompany, yearssincelastpromotion
FROM hr_employee_data
WHERE yearssincelastpromotion = yearsatcompany
  AND attrition = 'No'
ORDER BY yearsatcompany DESC;

--Build a retention risk profile — flag high-risk employees.
SELECT employeenumber, age, department, jobrole, monthlyincome,
        overtime, jobsatisfaction, worklifebalance, yearssincelastpromotion,
        CASE
          WHEN overtime = 'Yes'
                AND jobsatisfaction <= 2
                AND worklifebalance <= 2
                AND yearssincelastpromotion >=3
          THEN 'high risk'
          WHEN overtime = 'Yes' OR jobsatisfaction <= 2
          THEN 'medium risk'
          ELSE 'low risk'
        END AS retention_risk
FROM hr_employee_data
WHERE attrition = 'No'
ORDER BY retention_risk, monthlyincome ASC;



































