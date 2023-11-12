/*
Q1 : 
Assume you're given a table Twitter tweet data, `
write a query to obtain a histogram of tweets posted per user in 2022. 
Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.
In other words, group the users by the number of tweets they posted in 2022 and count the number of users in each group.
*/
SELECT num AS tweet_bucket, COUNT(*) AS users_num FROM
(
SELECT user_id, COUNT(*) AS num FROM
(
SELECT user_id, EXTRACT(year FROM tweet_date) AS YEAR 
FROM tweets WHERE EXTRACT(year FROM tweet_date) = 2022) AS Q1
GROUP BY user_id) AS Q2 
GROUP BY num ORDER BY users_num DESC;

---------------------------------------------------------------

/*

Common Table Expressions

A Common Table Expression (CTE) is a construct used to temporarily store the result set of a specified query 
such that it can be referenced by sub-sequent queries. 
The result of a CTE is not persisted on the disk but instead, 
its lifespan lasts till the execution of the query (or queries) referencing it.

Users can take advantage of CTEs such that complex queries are split into easier to maintain and read sub-queries. 
Additionally, Common Table Expressions can be referenced multiple times within a single query 
which means that you don’t have to repeat yourself. 
Given that CTEs are named, it also means that users can make it clear to 
the reader as what a particular expression is supposed to return as a result.

Multiple CTEs can be specified within a single query, 
each being comma-separated by others. 


WITH CTE AS (...): 
This starts by defining a Common Table Expression (CTE) named CTE. 
The CTE query retrieves the user_id and the count of tweet_ids for each user from the tweets table, 
filtered to consider only tweets from the year 2022. 
It groups the results by the user_id.

*/

WITH count_tweets AS
(
SELECT user_id AS user, COUNT(tweet_id) AS number
FROM tweets
WHERE EXTRACT(year FROM tweet_date) = '2022'
GROUP BY user_id
)

SELECT number AS tweet_bucket,COUNT(user) AS users_num
FROM count_tweets
GROUP BY number;


/*
Q2:
Given a table of candidates and their skills, 
you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient 
in Python, Tableau, and PostgreSQL.
Write a query to list the candidates who possess all of the required skills for the job. 
Sort the output by candidate ID in ascending order.
*/

SELECT candidate_id FROM candidates WHERE skill IN
('Python','PostgreSQL','Tableau') GROUP BY candidate_id
HAVING COUNT(*) = 3 ORDER BY candidate_id;

SELECT candidate_id FROM candidates WHERE skill = 'Python'
INTERSECT 
SELECT candidate_id FROM candidates WHERE skill = 'Tableau'
INTERSECT  
SELECT candidate_id FROM candidates WHERE skill = 'PostgreSQL'
ORDER BY 1;

/*

CASE Syntax

CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END;

Example :

SELECT OrderID, Quantity,
CASE
    WHEN Quantity > 30 THEN 'The quantity is greater than 30'
    WHEN Quantity = 30 THEN 'The quantity is 30'
    ELSE 'The quantity is under 30'
END AS QuantityText
FROM OrderDetails;

Output:

OrderID	Quantity	QuantityText
10248	12	The quantity is under 30
10248	10	The quantity is under 30
10248	5	The quantity is under 30

*/

SELECT candidate_id 
FROM candidates
GROUP BY candidate_id 
HAVING COUNT(CASE WHEN skill in ('Python','Tableau','PostgreSQL') THEN 1
ELSE NULL END)=3 
ORDER BY candidate_id


/*
Q3:

Assume you're given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").
Write a query to return the IDs of the Facebook pages that have zero likes. 
The output should be sorted in ascending order based on the page IDs.

*/

SELECT page_id FROM pages WHERE page_id NOT IN
(SELECT DISTINCT pages.page_id FROM pages,page_likes 
WHERE pages.page_id = page_likes.page_id);

SELECT page_id
FROM pages
WHERE PAGE_ID NOT IN (
		SELECT page_id
		FROM page_likes)
ORDER BY page_id ASC;

/*
Q4:

Tesla is investigating production bottlenecks and 
they need your help to extract the relevant data. 
Write a query to determine which parts have begun the assembly process but are not yet finished.

Assumptions:

parts_assembly table contains all parts currently in production, each at varying stages of the assembly process.
An unfinished part is one that lacks a finish_date.
This question is straightforward, so let's approach it with simplicity in both thinking and solution.

*/

SELECT part,assembly_step FROM parts_assembly 
WHERE finish_date IS NULL;

/*
Q5:

Assume you're given the table on user viewership categorised by device type where the three types are laptop, tablet, and phone.

Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined 
as the sum of tablet and phone viewership. Output the total viewership for laptops as laptop_reviews and the 
total viewership for mobile devices as mobile_views.

*/

SELECT (
SELECT COUNT(*) FROM 
viewership WHERE device_type = 'laptop') AS laptop_reviews, 
(SELECT COUNT(*) FROM 
viewership WHERE device_type IN ('phone','tablet')) AS mobile_views ;

--- USING FILTER
SELECT
COUNT(*) filter( WHERE device_type='laptop') as laptop_views,
COUNT(*) filter( WHERE device_type not in('laptop')) as mobile_views
from viewership;


--- USING CASE
SELECT 
  SUM(CASE WHEN device_type = 'laptop' THEN 1 ELSE 0 END) AS laptop_views, 
  SUM(CASE WHEN device_type IN ('tablet', 'phone') THEN 1 ELSE 0 END) AS mobile_views 
FROM viewership;

--- USING JOIN
select count(Distinct a.user_id) as "laptop_views", 
count(Distinct b.user_id) as "mobile_views"
from viewership as a
inner Join viewership as b 
on  a.device_type='laptop' and b.device_type in ('tablet', 'phone')

--- USING CTE
WITH CTE1 AS (
SELECT COUNT(device_type) AS laptop_Views FROM Viewership
WHERE device_type = 'laptop')
,
CTE2 AS (
SELECT COUNT(device_type) AS mobile_views FROM Viewership
WHERE device_type IN ('tablet','phone'))

SELECT laptop_views, mobile_views FROM CTE1 
JOIN CTE2 
ON 1=1

/*
Q6:

Given a table of Facebook posts, for each user who posted at least twice in 2021, 
write a query to find the number of days between each user’s first post of the year 
and last post of the year in the year 2021. 
Output the user and number of the days between each user's first and last post.

*/

SELECT * FROM (SELECT user_id, EXTRACT(DAY FROM LAST-FIRST) AS days_between FROM
(SELECT user_id, MAX(post_date) AS LAST, 
MIN(post_date) AS FIRST FROM posts WHERE 
EXTRACT(YEAR FROM post_date) = 2021 GROUP BY user_id) 
AS Q1) AS Q2 WHERE days_between > 0 ORDER BY days_between DESC;

SELECT user_id, EXTRACT(DAY FROM (MAX(post_date) - MIN(post_date))) AS "days_between"
FROM posts
WHERE post_date BETWEEN '2021-01-01' AND '2021-12-31'
GROUP BY user_id
HAVING count(post_id) > 1;

select user_id
, extract(day from max(post_date)-min(post_date)) from posts
where extract(year from post_date) = 2021
group by user_id
having min(post_date) != max(post_date);

/*
Q7:

Write a query to identify the top 2 Power Users who sent the highest number of messages 
on Microsoft Teams in August 2022. 
Display the IDs of these 2 users along with the total number of messages they sent. 
Output the results in descending order based on the count of the messages.

*/

SELECT sender_id, COUNT(*) AS message_count FROM messages 
WHERE EXTRACT(MONTH FROM sent_date) = 8 AND 
EXTRACT(YEAR FROM sent_date) = 2022
GROUP BY sender_id ORDER BY message_count DESC LIMIT 2;

WITH my_table AS (
        SELECT sender_id,COUNT(content) as message_count
        FROM messages
        WHERE EXTRACT(MONTH FROM sent_date) = 08 and 
        EXTRACT(YEAR FROM sent_date) = 2022
        GROUP BY sender_id)

SELECT * FROM my_table
ORDER BY message_count DESC
LIMIT 2;


SELECT 
  sender_id,
  COUNT(sent_date) AS message_count
FROM messages
WHERE sent_date BETWEEN '2022-08-01' AND '2022-08-31'
GROUP BY sender_id 
ORDER BY message_count DESC
LIMIT 2

/*
Q8:

Assume you're given a table containing job postings from various companies on the 
LinkedIn platform. Write a query to 
retrieve the count of companies that have posted duplicate job listings.

Definition:

Duplicate job listings are defined as two job listings within the 
same company that share identical titles and descriptions.

*/

SELECT COUNT(*) AS duplicate_companies FROM 
(SELECT DISTINCT T1.company_id FROM job_listings T1 
INNER JOIN job_listings T2 ON 
T1.company_id = T2.company_id AND 
T1.job_id != T2.job_id AND 
T1.title = T2.title AND 
T1.description = T2.description) AS Q1;

WITH company AS
(SELECT company_id FROM job_listings
GROUP BY company_id, title, description
HAVING COUNT(*) > 1)

SELECT COUNT(*) FROM company
