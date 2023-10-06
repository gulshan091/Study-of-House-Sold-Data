select*from random_data;
select*from agent;
select*from agent_commission;
select*from zip_population;

CREATE TABLE joined_result AS
SELECT agent."Brokerage Firm", random_data.*
FROM random_data
RIGHT JOIN agent ON random_data."agent_name"=agent."agent_name_i"
AND random_data."Zip" = agent."Zip_i";

select*from joined_result;

CREATE TABLE compl_table AS
SELECT zip_population."population", joined_result.*
FROM joined_result
LEFT JOIN zip_population ON zip_population."zip"=joined_result."Zip";
select * from compL_table;

ALTER TABLE compl_table
ADD COLUMN commission double precision;

UPDATE compl_table
SET commission =  
    CASE
        WHEN home_sub_type = 'Land' THEN 0.04 * sold_price
        WHEN home_sub_type = 'Commercial' THEN 0.05 * sold_price
        WHEN home_sub_type = 'Residential' THEN 0.032 * sold_price
        WHEN home_sub_type = 'Rental' THEN 0.08 * sold_price
        ELSE 0.0 -- Default value if none of the conditions match
    END;
	
select*from compl_table;

DELETE FROM compl_table
WHERE population IS NULL;
	
SELECT 
    COUNT(*) as total_rows,
    COUNT(CASE WHEN home_sub_type IS NULL THEN 1 ELSE NULL END) as missing_values_count
FROM 
    compl_table;

SELECT 
    COUNT(*) as total_rows,
    SUM(REGEXP_COUNT(home_fam_type, 'Null')) as Null
FROM 
    compl_table;
	
ALTER TABLE compl_table
DROP COLUMN home_fam_type;

SELECT home_sub_type
FROM compl_table
GROUP BY home_sub_type
ORDER BY COUNT(*) DESC
LIMIT 4;

UPDATE compl_table
SET home_sub_type = COALESCE(home_sub_type, 'Rental');

select*from compl_table;


COPY "public".compl_table TO 
'D:\realstate.csv' WITH CSV HEADER;
