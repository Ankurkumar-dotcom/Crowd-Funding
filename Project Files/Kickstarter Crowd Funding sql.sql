use crowd_funding;

-- Drop and recreate the table with the same order as CSV

CREATE TABLE project (
    created_at_new VARCHAR(25),
    id BIGINT,
    state VARCHAR(20),
    name TEXT,
    country CHAR(20),
    creator_id BIGINT,
    location_id BIGINT,
    category_id varchar(20),
    financial_quarter VARCHAR(10),
    financial_month VARCHAR(10),
    week_day_name VARCHAR(10),
    week_day_number INT,
    yearmonth VARCHAR(10),
    quarter VARCHAR(10),
    month_full_name VARCHAR(15),
    month_number INT,
    year INT,
    created_at BIGINT,
    deadline_new VARCHAR(25),
    deadline BIGINT,
    updated_at_new VARCHAR(25),
    updated_at BIGINT,
    state_changed_at_new VARCHAR(25),
    state_changed_at BIGINT,
    launched_at_new VARCHAR(25),
    launched_at BIGINT,
    goal_usd VARCHAR(50),
    goal_range VARCHAR(50),
    goal BIGINT,
    pledged BIGINT,
    currency VARCHAR(10),
    currency_symbol VARCHAR(5),
    usd_pledged BIGINT,
    static_usd_rate INT,
    backers_count INT
);



SHOW VARIABLES LIKE '%dir%';

SHOW VARIABLES LIKE 'secure_file_priv';

load DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Data/project.csv"
INTO TABLE project
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select count(*) from project;

select * from project;



# Total Number of Projects based on outcome 

select 
      count(id),state as outcome 
from 
     project 
group by 
        state;

#Total Number of Projects based on Locations

SELECT 
    l.state,
    l.country,
    COUNT(p.id) AS total_projects
FROM project p
INNER JOIN location l ON p.location_id = l.id
GROUP BY l.state, l.country
ORDER BY total_projects DESC;

#    Total Number of Projects based on  Category

SELECT 
    c.name AS category_name,
    COUNT(p.id) AS total_projects
FROM project p
INNER JOIN category c ON p.category_id = c.id
GROUP BY c.name
ORDER BY total_projects DESC;

desc category;
ALTER TABLE category RENAME COLUMN ï»¿id  TO id;




#  Total Number of Projects created by Year , Quarter , Month

SELECT
    YEAR AS project_year,
    QUARTER AS project_quarter,
    month_full_name AS project_month,
    COUNT(*) AS id
FROM
    project
GROUP BY
    project_year,
    project_quarter,
    project_month
ORDER BY
    project_year,
    project_quarter,
    project_month;
    
    
 # Amount rasied by succesful project
 

    
    SELECT 
    SUM(usd_pledged) AS total_amount_raised
FROM 
    project
WHERE 
    state = 'successful';

# Number of backers from successful project

select sum(backers_count) as Number_of_backers_from_successful_project
 from 
       project
 where  
           state = 'successful'; 
           
# Average number of days for successful project 

SELECT 
    round(AVG(DATEDIFF(FROM_UNIXTIME(deadline), FROM_UNIXTIME(launched_at))),2) 
AS avg_project_duration_days
FROM 
    project
WHERE 
    state = 'successful';
    
    
    
#Top Successful Projects Based on Number of Backers

SELECT 
    name AS project_name,
    backers_count as 'number of beckers'
FROM 
    project
WHERE 
    state = 'successful'
ORDER BY 
    backers_count DESC
LIMIT 10;

# Top Successful Projects Based on Amount Raised.

SELECT 
    id AS project_id,
    name AS project_name,
    usd_pledged as "amount raised"

FROM 
    project
WHERE 
    state = 'successful'
ORDER BY 
    usd_pledged DESC
LIMIT 10;


#Percentage of Successful Projects overall


SELECT 
    ROUND(
        (SUM(CASE WHEN state = 'successful' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 
        2
    ) AS success_percentage
FROM 
    project;
    
    
#  Percentage of Successful Projects  by Category
    
    SELECT 
    c.name AS category_name,
    ROUND(
        (SUM(CASE WHEN p.state = 'successful' THEN 1 ELSE 0 END) * 100.0) / COUNT(*),
        2
    ) AS success_percentage
FROM 
    project p
INNER JOIN 
    category c ON p.category_id = c.id
GROUP BY 
    c.name
ORDER BY 
    success_percentage DESC;
    


# Percentage of Successful Projects by Year , Month etc..

SELECT 
    YEAR(FROM_UNIXTIME(launched_at)) AS launch_year,
    MONTH(FROM_UNIXTIME(launched_at)) AS launch_month,
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0) / COUNT(*) AS success_percentage
FROM 
    project
GROUP BY 
    launch_year, launch_month
ORDER BY 
    launch_year, launch_month;
    
    
# Percentage of Successful projects by Goal Range 
    
SELECT 
  CASE 
    WHEN goal < 5000 THEN 'Less than $5K'
    WHEN goal BETWEEN 5000 AND 20000 THEN '$5K - $20K'
    WHEN goal BETWEEN 20001 AND 50000 THEN '$20K - $50K'
    WHEN goal BETWEEN 50001 AND 100000 THEN '$50K - $100K'
    ELSE 'Above $100K'
  END AS goal_range,

  ROUND(
    (COUNT(CASE WHEN state = 'successful' THEN 1 END) * 100.0) / COUNT(*),
    2
  ) AS success_percentage

FROM project
GROUP BY goal_range
ORDER BY success_percentage DESC;

    

    
    



