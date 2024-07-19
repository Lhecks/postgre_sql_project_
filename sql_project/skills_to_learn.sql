-- Displaying the top 20 most demanded skills

WITH skills_to_study AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS skills_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' AND job_work_from_home = TRUE 
        AND salary_year_avg IS NOT NULL
        -- AND job_location = 'Anywhere'
    GROUP BY
        skills_dim.skill_id
), average_salary AS (
    SELECT 
        skills_job_dim.skill_id,
        -- skills,
        ROUND(AVG(salary_year_avg), 0) AS salary_avg
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
        -- job_work_from_home = TRUE
        -- AND job_location = 'Anywhere'
    GROUP BY
        skills_job_dim.skill_id
)

SELECT 
    skills_to_study.skill_id,
    skills_to_study.skills,
    skills_count,
    salary_avg
FROM 
    skills_to_study

INNER JOIN average_salary ON skills_to_study.skill_id = average_salary.skill_id
WHERE
    skills_count>10
ORDER BY average_salary.salary_avg DESC;

-- Or in a very Simple Way

SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS skills_count,
    ROUND(AVG(job_postings_fact.salary_year_avg), 0) AS salary_avg
FROM 
    job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL
    -- job_work_from_home = TRUE
    AND job_location = 'Anywhere'
GROUP BY
    skills_dim.skill_id
HAVING
    COUNT(skills_job_dim.job_id)>10
ORDER BY 
    salary_avg DESC
-- LIMIT 20