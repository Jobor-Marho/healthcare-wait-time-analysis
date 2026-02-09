-- Script to Create 'location' table

CREATE TABLE location(
    id INT PRIMARY KEY,
    name VARCHAR(50)
);


-- Remodyfing table and column name

-- ALTER TABLE locations
-- ALTER COLUMN location_name SET NOT NULL;
-- RENAME to locations
-- -- RENAME COLUMN id TO location_id;

-- RENAME COLUMN name TO location_name;



-- Script to create 'departments' table

CREATE TABLE departments(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(60) NOT NULL
);

-- Script to create 'patients' table

CREATE TABLE patients(
    id INT PRIMARY KEY,
    check_in_time TIMESTAMPTZ NOT NULL,
    check_out_time TIMESTAMPTZ NOT NULL,
    department_id INT REFERENCES departments(department_id) NOT NULL,
    location_id INT REFERENCES locations(location_id) NOT NULL
    CHECK(check_out_time >= check_in_time)
);



-- Copy data into their corresponding tables

-- locations
COPY 
    locations 
FROM 
    'C:/pgdata/locations.csv' 
DELIMITER ',' 
CSV HEADER;

-- departments
COPY 
    departments 
FROM 
    'C:/pgdata/departments.csv' 
DELIMITER ',' 
CSV HEADER;

--- patients 
COPY 
    patients 
FROM 
    'C:/pgdata/patients.csv' 
DELIMITER ',' 
CSV HEADER;


-- Display all table values

-- Locations
SELECT
    *
FROM
    locations;

-- departments
SELECT 
    *
FROM
    departments;

-- patients
SELECT 
    *
FROM
    patients;


-- Calculate Wait_Time Per patients

WITH wait_times AS (
    SELECT
        id as patient_id,
        department_id,
        location_id,
        ROUND(EXTRACT(EPOCH FROM(check_out_time - check_in_time))/60,2) AS wait_minutes

    FROM
        patients 
    WHERE
        check_out_time IS NOT NULL AND check_in_time IS NOT NULL
     
)
SELECT
    *
FROM
    wait_times;


-- Calculate Average Wait time Per location
WITH wait_times AS (
    SELECT
        id as patient_id,
        department_id,
        location_id,
        ROUND(EXTRACT(EPOCH FROM(check_out_time - check_in_time))/60,2) AS wait_minutes

    FROM
        patients 
    WHERE
        check_out_time IS NOT NULL AND check_in_time IS NOT NULL
     
),
loc_avg_wait_time AS(
    SELECT
        l.location_name,
        ROUND(AVG(wait_minutes),2) AS avg_wait_minutes
    FROM 
        wait_times w
    INNER JOIN
        locations l
    ON
        w.location_id = l.location_id
    GROUP BY
        l.location_name
    ORDER BY
        l.location_name;
)

-- SELECT
--     *
-- FROM
--     wait_times;

-- wont run as cte only used upon successful call from the first select statement that refrence it
SELECT
    *
FROM
    loc_avg_wait_time;
    

-- In order not to have duplicate wait_time cte scrip, lets create a temporary table that tracks the wait_time

CREATE TEMP TABLE wait_times AS (
    SELECT
        id as patient_id,
        department_id,
        location_id,
        ROUND(EXTRACT(EPOCH FROM(check_out_time - check_in_time))/60,2) AS wait_minutes

    FROM
        patients 
    WHERE
        check_out_time IS NOT NULL AND check_in_time IS NOT NULL
);

-- Now we can display wait time without having to receate a cte with wait_time

SELECT  *

FROM
    wait_times;


-- we can also display the avg wait_time per location without repeating the initilization of the wait_time cte

SELECT
    loc.location_name,
    ROUND(AVG(w.wait_minutes),2) AS avg_wait_minutes
FROM 
    wait_times w
INNER JOIN
    locations loc
ON
    w.location_id = loc.location_id
GROUP BY
    loc.location_name
ORDER BY
    avg_wait_minutes DESC;

-- identify problem location (with wait_time > 120 mins)

SELECT 
    loc.location_name,
    ROUND(AVG(w.wait_minutes),2) AS avg_wait_minutes
FROM 
    wait_times w
INNER JOIN
    locations loc
ON
    w.location_id = loc.location_id
GROUP BY
    loc.location_name
HAVING 
    ROUND(AVG(w.wait_minutes),2) > 120
ORDER BY 
    avg_wait_minutes
DESC;

-- Department Level bottle neck

SELECT 
    d.department_name,
    ROUND(AVG(w.wait_minutes),2) AS avg_wait_minutes
FROM
    wait_times w
JOIN
    departments d
ON
    d.department_id = w.department_id
GROUP BY
    d.department_name
ORDER BY 
    avg_wait_minutes
DESC;
    

-- Departments with wait time > 120mins


SELECT 
    d.department_name,
    ROUND(AVG(w.wait_minutes),2) AS avg_wait_minutes
FROM
    wait_times w
JOIN
    departments d
ON
    d.department_id = w.department_id
GROUP BY
    d.department_name
HAVING 
    ROUND(AVG(w.wait_minutes),2) > 120
ORDER BY 
    avg_wait_minutes
DESC;


-- % of Locations with High Wait Times 

CREATE TEMP TABLE location_avg_wait_time AS (
    SELECT
        location_id,
        ROUND(
            AVG(
                EXTRACT(EPOCH FROM (check_out_time - check_in_time))
            ) / 60,
            2
        ) AS avg_wait_minutes
    FROM patients
    WHERE check_in_time IS NOT NULL
      AND check_out_time IS NOT NULL
    GROUP BY location_id
);

SELECT 
    COUNT(*) FILTER (WHERE avg_wait_minutes > 120) AS no_of_high_wait_time_location,
    COUNT(*) AS no_of_locations,
    ROUND(
        COUNT(*) FILTER (WHERE avg_wait_minutes > 120) * 100.0
        / COUNT(*),
        2
    ) AS percentage_of_high_wait_time_location
FROM location_avg_wait_time;


-- Monthly Trends of % of High-Wait Locations

SELECT DATE_TRUNC('month',check_in_time)
FROM patients;



WITH monthly_location_avg AS (
    SELECT
        DATE_TRUNC('month', check_in_time) AS month,
        location_id,
        AVG(
            EXTRACT(EPOCH FROM (check_out_time - check_in_time))
        ) / 60 AS avg_wait_minutes
    FROM patients
    WHERE check_in_time IS NOT NULL
      AND check_out_time IS NOT NULL
    GROUP BY
        month,
        location_id
)

SELECT
    TO_CHAR(month, 'Mon YYYY') AS month,
    COUNT(*) FILTER (WHERE avg_wait_minutes > 120) AS high_wait_locations,
    COUNT(*) AS total_locations,
    ROUND(
        COUNT(*) FILTER (WHERE avg_wait_minutes > 120) * 100.0
        / COUNT(*),
        2
    ) AS pct_high_wait_locations
FROM monthly_location_avg
GROUP BY month
ORDER BY month;
