CREATE DATABASE LOAN;
USE LOAN;
SELECT * FROM LOAN_DATA;
SELECT COUNT(*) FROM LOAN_DATA;  #45k
SELECT DISTINCT COUNT(*) FROM LOAN_DATA;  #No duplicates
DESCRIBE LOAN_DATA;
SELECT MIN(PERSON_INCOME) FROM LOAN_DATA;

#------Null value checking------
SELECT * FROM LOAN_DATA WHERE person_age IS NULL OR person_gender IS NULL OR person_education IS NULL OR person_income IS NULL OR
person_emp_exp IS NULL OR person_home_ownership IS NULL OR loan_amnt IS NULL OR loan_intent IS NULL OR loan_int_rate IS NULL or
loan_percent_income IS NULL OR cb_person_cred_hist_length  IS NULL OR credit_score IS NULL OR previous_loan_defaults_on_file IS NULL OR
loan_status IS NULL;

#------Adding a new column------
SET SQL_SAFE_UPDATES=0;

#1.Income Category
ALTER TABLE LOAN_DATA ADD COLUMN INCOME_CATEGORY VARCHAR(50);
UPDATE LOAN_DATA SET INCOME_CATEGORY= CASE
WHEN PERSON_INCOME<=40000 THEN 'LOW'
WHEN PERSON_INCOME BETWEEN 40000 AND 80000 THEN 'MODERATE'
ELSE 'HIGH'
END; 
SELECT * FROM LOAN_DATA;

#2.Credit Score Category
ALTER TABLE LOAN_DATA ADD COLUMN CREDIT_SCORE_CATEGORY VARCHAR(50);
UPDATE LOAN_DATA SET CREDIT_SCORE_CATEGORY=CASE
WHEN CREDIT_SCORE<=600 THEN 'LOW'
WHEN CREDIT_SCORE BETWEEN 600 AND 700 THEN 'FAIR'
ELSE 'HIGH'
END;
SELECT * FROM LOAN_DATA;

#3.Debt-to-Income ratio
ALTER TABLE loan_data ADD COLUMN dti_ratio FLOAT;
UPDATE LOAN_DATA SET DTI_RATIO = LOAN_AMNT / PERSON_INCOME * 100;  #HIGHER DTI_RATIO,HIGHER BURDEN
SELECT * FROM LOAN_DATA;

#Age categorisation
ALTER TABLE LOAN_DATA ADD COLUMN AGE_CATEGORY VARCHAR(50);
UPDATE LOAN_DATA SET AGE_CATEGORY=CASE 
        WHEN person_age < 25 THEN 'Young Adult'
        WHEN person_age BETWEEN 25 AND 40 THEN 'Adult'
        WHEN person_age BETWEEN 40 AND 60 THEN 'Middle-aged'
        ELSE 'Senior'
    END;

#------Outlier Handling------
#1.Person Age Outliers:
DELETE FROM loan_data WHERE person_age > 100;

SELECT COUNT(*) FROM LOAN_DATA;  #44993

-- SELECT COUNT(*) FROM LOAN_DATA where person_income>1000000;
-- select * from loan_data where person_income>1000000; 
#-----------------------------------------------------------------UNIVARIATE ANALYSIS------------------------------------------------------------
#1.Income statistics
SELECT 
    MIN(person_income) AS min_income,  #8000
    MAX(person_income) AS max_income,  #2448661
    AVG(person_income) AS avg_income,  #79908.44758073478
    STDDEV(person_income) AS stddev_income  #63321.42865625254
FROM loan_data;

#2.Distribution by income ranges  -->RESULT:Most people comes under 50 to 100k range. and least in under 20k range
SELECT CASE 
        WHEN person_income < 20000 THEN 'Under 20K'
        WHEN person_income BETWEEN 20000 AND 50000 THEN '20K-50K'
        WHEN person_income BETWEEN 50000 AND 100000 THEN '50K-100K'
        ELSE 'Over 100K'
    END AS income_range,
    COUNT(*) AS count
FROM loan_data
GROUP BY income_range
ORDER BY count DESC;

#3.Loan_Intent  -->RESULT:So most people took loan for 'Education' and least for 'Home Improvement'.
SELECT LOAN_INTENT,COUNT(*) AS COUNT_OF_EACH FROM LOAN_DATA GROUP BY LOAN_INTENT ORDER BY COUNT_OF_EACH DESC;

#4.Person_age  -->RESULT:Highest age_group-23(5254). so mostly the age range is in b/w 20 and 30
SELECT PERSON_AGE,COUNT(*) AS AGE_COUNT FROM LOAN_DATA GROUP BY PERSON_AGE ORDER BY AGE_COUNT desc;  #Age range-20 to 144(So there are outliers)
SELECT AGE_CATEGORY,COUNT(*) AS AGE_COUNT FROM LOAN_DATA GROUP BY AGE_CATEGORY ORDER BY AGE_COUNT desc;  #Highest->Adult-27227

#5.Gender:
SELECT PERSON_GENDER,COUNT(*) AS GENDER_COUNT FROM LOAN_DATA GROUP BY PERSON_GENDER ORDER BY GENDER_COUNT DESC;#Male-24841,Female-20159

#6.Education  -->RESULT:Most of them 'Bachelors' degree holder and least Doctorate.There are a total of 5categories
SELECT PERSON_EDUCATION,COUNT(*) AS EDU_COUNT FROM LOAN_DATA GROUP BY PERSON_EDUCATION ORDER BY EDU_COUNT DESC;

#7.Loan Amount Statistics
SELECT 
    MIN(loan_amnt) AS min_amnt,  #500
    MAX(loan_amnt) AS max_amnt,  #35000
    AVG(loan_amnt) AS avg_amnt,  #9583.157555555556
    STDDEV(loan_amnt) AS stddev_amnt  #6314.816524743697
FROM loan_data;

#8.Employee experience count  #Most of the people who took loan have '0' years experience
SELECT PERSON_EMP_EXP,COUNT(*) AS EXP_COUNT FROM LOAN_DATA GROUP BY PERSON_EMP_EXP ORDER BY EXP_COUNT DESC;

#9.Home Ownership,most people lives for 'Rent'
SELECT person_home_ownership,COUNT(*) AS ownership_count FROM loan_data GROUP BY person_home_ownership ORDER BY ownership_count DESC;

#10.Loan Interest Rate Analysis
SELECT 
    MIN(loan_int_rate) AS min_int_rate,  -- Lowest interest rate--5.42
    MAX(loan_int_rate) AS max_int_rate,  -- Highest interest rate--20
    AVG(loan_int_rate) AS avg_int_rate,  -- Average interest rate--11.00644789189424
    STDDEV(loan_int_rate) AS stddev_int_rate  -- Standard deviation of interest rates--2.9789523311281356
FROM loan_data;

#11.Credit History Length Analysis
SELECT 
    MIN(cb_person_cred_hist_length) AS min_hist_length,  #2
    MAX(cb_person_cred_hist_length) AS max_hist_length,  #30
    AVG(cb_person_cred_hist_length) AS avg_hist_length,  #5.866557019980886
    STDDEV(cb_person_cred_hist_length) AS stddev_hist_length  #3.8771238852626158
FROM loan_data;

#12. Loan Amount to Income Ratio Analysis
SELECT 
    MIN(loan_percent_income) AS min_percent_income,  #0
    MAX(loan_percent_income) AS max_percent_income,  #0.66--66% of their income goes to loan
    AVG(loan_percent_income) AS avg_percent_income,  #0.14
    STDDEV(loan_percent_income) AS stddev_percent_income  #0.09
FROM loan_data;
SELECT * FROM LOAN_DATA WHERE LOAN_PERCENT_INCOME=0 ;

#13.Debt-to-income ratio 
SELECT 
    MIN(dti_ratio) AS min,  #0.0657612
    MAX(dti_ratio) AS max,  #66.4186
    AVG(dti_ratio) AS avg,  #14
    STDDEV(dti_ratio) AS stddev  #8.71
FROM loan_data;
#for categorization-->RESULT:Highest in Under 20%
SELECT CASE 
        WHEN dti_ratio < 20 THEN 'Under 20%'
        WHEN dti_ratio BETWEEN 20 AND 35 THEN '20%-35%'
        WHEN dti_ratio BETWEEN 35 AND 50 THEN '35%-50%'
        ELSE 'Over 50%'
    END AS dti_range,
    COUNT(*) AS count
FROM loan_data
GROUP BY dti_range
ORDER BY count DESC;

#14.Loan Status Analysis-->RESULT:0(Rejected)-34993,1(Approved)-10000
SELECT loan_status, COUNT(*) AS count FROM loan_data GROUP BY loan_status ORDER BY count DESC;

#----------------------------------------------------------------BIVARIATE ANALYSIS--------------------------------------------------------------
SELECT * FROM LOAN_DATA;
#1.Home Ownership Analysis by Loan Intent(To explore if loan purpose varies with homeownership)
SELECT PERSON_HOME_OWNERSHIP,LOAN_INTENT,COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY PERSON_HOME_OWNERSHIP,LOAN_INTENT ORDER BY COUNT DESC;

#2.Analyzing Income Category vs Average Loan Amount-->Moderate tale more loan_amt but their avg loan amount is less compared to high category,because they borrow money only which they can return.
SELECT INCOME_CATEGORY,AVG(LOAN_AMNT) AS AVG_LOAN_AMT,COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY INCOME_CATEGORY ORDER BY COUNT DESC;

#3.Loan Purposes by Income Category-->Mostly by moderate for eduacation and medical purposes.
SELECT INCOME_CATEGORY, LOAN_INTENT, COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY INCOME_CATEGORY, LOAN_INTENT ORDER BY COUNT DESC;

#4.Age Category vs Loan Intent
SELECT AGE_CATEGORY, LOAN_INTENT, COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY AGE_CATEGORY, LOAN_INTENT ORDER BY COUNT DESC;

#5.Loan Status vs Income Category
SELECT INCOME_CATEGORY, LOAN_STATUS, COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY INCOME_CATEGORY, LOAN_STATUS ORDER BY INCOME_CATEGORY, LOAN_STATUS;

 #6.Loan Intent vs. Credit Score Category
SELECT LOAN_INTENT, CREDIT_SCORE_CATEGORY, COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY LOAN_INTENT, CREDIT_SCORE_CATEGORY ORDER BY LOAN_INTENT, COUNT DESC;
#SELECT COUNT(*) FROM LOAN_DATA WHERE LOAN_INTENT="HOMEIMPROVEMENT" AND LOAN_STATUS=1;  #0-->1258,1-->3525,so most of them are rejected.

#7.Loan_Intent vs. Loan_Status
SELECT LOAN_INTENT, LOAN_STATUS, COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY LOAN_INTENT, LOAN_STATUS ORDER BY LOAN_INTENT, LOAN_STATUS;

#8.Gender vs.Loan Approval rate
SELECT PERSON_GENDER,LOAN_STATUS,COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY PERSON_GENDER,LOAN_STATUS ORDER BY PERSON_GENDER;

SELECT PERSON_GENDER,
    SUM(CASE WHEN LOAN_STATUS = '1' THEN 1 ELSE 0 END) AS Approved_Loans,
    SUM(CASE WHEN LOAN_STATUS = '0' THEN 1 ELSE 0 END) AS Denied_Loans,
    COUNT(*) AS Total_Loans,
    ROUND(SUM(CASE WHEN LOAN_STATUS = '1' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Approval_Rate_Percentage
FROM LOAN_DATA GROUP BY PERSON_GENDER ORDER BY PERSON_GENDER;

#9.Loan status and Credit Score
SELECT CREDIT_SCORE_CATEGORY,LOAN_STATUS,COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY CREDIT_SCORE_CATEGORY, LOAN_STATUS ORDER BY LOAN_STATUS, COUNT DESC;

SELECT CREDIT_SCORE_CATEGORY,SUM(CASE WHEN LOAN_STATUS = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS APPROVAL_RATE 
FROM LOAN_DATA GROUP BY CREDIT_SCORE_CATEGORY;

#10.Analysis of DTI Ratio by Loan Status:
SELECT PERSON_GENDER,LOAN_INTENT,COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY PERSON_GENDER,LOAN_INTENT ORDER BY PERSON_GENDER,LOAN_INTENT;

#----------------------------------------------------------------MULTIVARIATE ANALYSIS------------------------------------------------------------
SELECT * FROM LOAN_DATA;
#1.Loan Status by Home Ownership and Employment Experience:
SELECT LOAN_STATUS,PERSON_HOME_OWNERSHIP,PERSON_EMP_EXP,COUNT(*) AS COUNT FROM LOAN_DATA GROUP BY PERSON_HOME_OWNERSHIP,PERSON_EMP_EXP,LOAN_STATUS 
ORDER BY LOAN_STATUS,COUNT DESC;

#Specific Focus on Renters with 0 Years of Experience
SELECT loan_status,COUNT(*) AS approval_count FROM loan_data WHERE person_home_ownership = 'RENT' AND person_emp_exp = 0 GROUP BY loan_status;

#Approval Rates Based on Credit Score for Renters with 0 Experience
SELECT credit_score_category,COUNT(CASE WHEN loan_status = 1 THEN 1 END) AS approved_count,COUNT(CASE WHEN loan_status = 0 THEN 1 END) 
AS not_approved_count FROM loan_data WHERE person_home_ownership = 'RENT' AND person_emp_exp = 0 GROUP BY credit_score_category;
#NOTE
-- Low Credit Score: Approval Rate = Approved / Total Count = 527 / 1,574 ≈ 33.5%
-- Fair Credit Score: Approval Rate = 1,234 / 3,602 ≈ 34.3%
-- High Credit Score:Approval Rate = 52 / 152 ≈ 34.2%
-- The approval rates across the different credit score categories are fairly similar, indicating that the approval process may not be
# strictly dependent on credit scores alone
#LOAN_INTENT
SELECT 
    loan_status,
    person_home_ownership,
    person_emp_exp,
    loan_intent,
    COUNT(*) AS count
FROM 
    loan_data
GROUP BY 
    loan_status, person_home_ownership, person_emp_exp, loan_intent
ORDER BY 
    loan_status, count DESC;
#AGE_CATEGORY
SELECT 
    LOAN_STATUS,
    PERSON_HOME_OWNERSHIP,
    PERSON_EMP_EXP,
   AGE_CATEGORY,
    COUNT(*) AS COUNT
FROM 
    LOAN_DATA
GROUP BY 
    LOAN_STATUS, 
    PERSON_HOME_OWNERSHIP, 
    PERSON_EMP_EXP, 
    AGE_CATEGORY
ORDER BY 
    LOAN_STATUS, 
    COUNT DESC;
#Examining Loan Amounts for Approved vs. Not Approved Renters
SELECT loan_status,AVG(loan_amnt) AS average_loan_amount FROM loan_data WHERE person_home_ownership = 'RENT' AND person_emp_exp = 0
GROUP BY loan_status;

    
#2.Debt-to-Income (DTI) Ratio Analysis by Loan Intent and Credit Score
SELECT loan_intent,credit_score_category,AVG(dti_ratio) AS avg_dti_ratio FROM loan_data GROUP BY loan_intent, credit_score_category
ORDER BY avg_dti_ratio DESC;



