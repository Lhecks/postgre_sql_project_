WITH top_jobs AS (
SELECT 
    job_id,
    name AS company_name,
    job_title,
    job_location,
    salary_year_avg
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    (job_title_short='Data Analyst' AND
    job_location='Anywhere') AND salary_year_avg IS NOT NULL
)
SELECT 
    top_jobs.*,
    skills
FROM top_jobs
INNER JOIN skills_job_dim ON top_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    top_jobs.salary_year_avg DESC
LIMIT 20