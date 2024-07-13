-- Working with date & time commands
SELECT 
    job_title_short AS TITLE,
    job_location AS LOCATION,
    job_posted_date AS DATE,
    job_posted_date:: DATE AS DATE_FORM,
    job_posted_date At TIME ZONE 'EST' AS DATE_ZONE,
    EXTRACT(MONTH FROM job_posted_date) AS MONTH,
    EXTRACT(YEAR FROM job_posted_date) AS YEAR
FROM 
    job_postings_fact
LIMIT 50;


SELECT 
    COUNT(job_id) AS NUM_ID,
    EXTRACT(MONTH FROM job_posted_date) AS MONTH
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    MONTH
LIMIT 30;

--Creating tables of each month of the year from the posting job
/*
CREATE TABLE january_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

CREATE TABLE april_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 4;

CREATE TABLE may_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 5;

CREATE TABLE october_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 10;

CREATE TABLE december_jobs AS
    SELECT *
    FROM 
        job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 12;
*/

-- Fetch all the data from the following table: april_jobs & october_jobs
SELECT * FROM april_jobs;
SELECT * FROM october_jobs;

SELECT 
    job_title_short,
    job_location,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE  'Onsite'
    END AS location_category
FROM job_postings_fact


/* 
    using the case when end statement to fetch all the data based on the location, 
    rename the location so we can have readable results.
    Grouping them by location_category
*/
SELECT 
    COUNT(job_id) AS number_jobs,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE  'Onsite'
    END AS location_category
FROM 
    job_postings_fact
GROUP BY 
    location_category

/* 
    using the case when end statement to fetch the data based on the location 
    With the condition of Data Analyst, 
    rename the location so we can have readable results.
    Grouping them by location_category
*/
SELECT 
    COUNT(job_id) AS number_jobs,
    CASE 
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE  'Onsite'
    END AS location_category
FROM 
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY 
    location_category

--Fetch the company's name where the dregree is mentioned
SELECT name AS company_name
FROM company_dim
WHERE company_id IN(
    SELECT 
        company_id
    FROM 
        job_postings_fact
    WHERE 
        job_no_degree_mention = true
)


--Fetch the company's name where the dregree is not mentioned
SELECT 
    name AS company_name,
FROM 
    company_dim
WHERE 
    company_id IN(
        SELECT 
            company_id
        FROM 
            job_postings_fact
        WHERE 
            job_no_degree_mention = FALSE
)

/*
    Looking for the company along with their total jobs
*/
WITH company_job_count AS(
    SELECT 
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY company_id
)

SELECT
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM
    company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC

/*
    Find the number of remote jobs per skills
*/
SELECT 
    skill_id,
    -- COUNT(*) 
    job_posting.job_id,
    job_posting.job_work_from_home AS Remote
FROM skills_job_dim AS skills_jobs
INNER JOIN job_postings_fact AS job_posting ON job_posting.job_id = skills_jobs.job_id
WHERE
    job_posting.job_work_from_home = True


WITH job_skills_for_remote AS (
SELECT 
    skill_id,
    COUNT(*) AS skill_count
FROM skills_job_dim AS skills_jobs
INNER JOIN job_postings_fact AS job_posting ON job_posting.job_id = skills_jobs.job_id
WHERE
    job_posting.job_work_from_home = True AND
    job_posting.job_title_short = 'Data Analyst'
GROUP BY
    skill_id
)

SELECT 
    skills.skill_id,
    skills AS skills_name,
    skill_count
FROM job_skills_for_remote
INNER JOIN skills_dim AS skills ON skills.skill_id = job_skills_for_remote.skill_id
ORDER BY 
    skill_count DESC
LIMIT 20