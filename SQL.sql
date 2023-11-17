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

/*
Q9:

Assume you're given the tables containing completed 
trade orders and user details in a Robinhood trading system.

Write a query to retrieve the top three cities that 
have the highest number of completed trade orders listed in 
descending order. Output the city name and the corresponding number of completed trade orders.

*/

SELECT U.city, COUNT(*) AS total_orders FROM trades T 
INNER JOIN users U ON T.user_id = U.user_id
WHERE T.status = 'Completed' GROUP BY U.city 
ORDER BY total_orders DESC LIMIT 3;


SELECT u.city, 
SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) as total_orders
FROM trades as t
JOIN users as u ON t.user_id = u.user_id
GROUP BY u.city
ORDER BY total_orders DESC
LIMIT 3;


/*
Q10 :

Given the reviews table, write a query to retrieve the average star rating for each product, 
grouped by month. The output should display the month as a 
numerical value, product ID, and average star rating rounded to two decimal places. 
Sort the output first by month and then by product ID.

*/

SELECT product_id, ROUND(AVG(stars),2) AS avg_stars,
EXTRACT(MONTH from submit_date) AS mth FROM reviews 
GROUP BY product_id,EXTRACT(MONTH from submit_date)
ORDER BY mth,product_id;

/*
Q11: 

Assume you have an events table on Facebook app analytics. Write a query to calculate the click-through rate (CTR) 
for the app in 2022 and round the results to 2 decimal places.

Definition and note:

Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
To avoid integer division, multiply the CTR by 100.0, not 100.

*/

SELECT Q1.app_id, ROUND(clk * 100.0 / imp, 2) AS ctr
FROM (
    SELECT app_id,COUNT(*) AS clk FROM events 
    WHERE event_type = 'click' AND EXTRACT(YEAR FROM timestamp) = 2022
    GROUP BY app_id) AS Q1,
    (
        SELECT app_id,COUNT(*) AS imp FROM events 
        WHERE event_type = 'impression' AND EXTRACT(YEAR FROM timestamp) = 2022
        GROUP BY app_id) AS Q2 
WHERE Q1.app_id = Q2.app_id;



SELECT app_id,
ROUND((100.0*  SUM(CASE WHEN event_type = 'click' THEN 1 ELSE 0 END)/
SUM(CASE WHEN event_type = 'impression' THEN 1 ELSE 0 END) 
    ),2) AS ctr
FROM events
WHERE EXTRACT(YEAR from timestamp) = '2022'
GROUP BY app_id;



WITH click_per_id AS (
SELECT app_id,
        COUNT(event_type) AS count_clicks
FROM events
WHERE event_type = 'click'
      AND EXTRACT(year FROM timestamp) = '2022'
GROUP BY app_id),

impression_per_id AS (
SELECT app_id, COUNT(event_type) AS count_impr
FROM events
WHERE event_type = 'impression'
      AND EXTRACT(year FROM timestamp) = '2022'
GROUP BY app_id)

SELECT clk.app_id,
        ROUND(100.0*clk.count_clicks/imp.count_impr,2) AS ctr
FROM click_per_id AS clk
LEFT JOIN impression_per_id AS imp
ON clk.app_id = imp.app_id;

/*

Q12 : Medium

Assume you are given the table below on Uber transactions made by users. 
Write a query to obtain the third transaction of every user. 
Output the user id, spend and transaction date.

*/

/*

The SQL PARTITION BY expression is a subclause of the OVER clause, 
which is used in almost all invocations of window functions like AVG(), 
MAX(), and RANK(). As many readers probably know, window functions operate 
on window frames which are sets of rows that can be different for each record in the query result. 
This is where the SQL PARTITION BY subclause comes in: it is used to define which records 
to make part of the window frame associated with each record of the result.

Examples :


SELECT
    car_make,
    car_model,
    car_price,
    AVG(car_price) OVER() AS "overall average price",
    AVG(car_price) OVER (PARTITION BY car_type) AS "car type average price"
FROM car_list_prices

SELECT first_name, last_name, level, years_experience,
       RANK() OVER (ORDER BY years_experience DESC),
       DENSE_RANK() OVER (ORDER BY years_experience DESC),
       ROW_NUMBER() OVER (ORDER BY years_experience DESC)
FROM developers;

SELECT first_name, last_name, level, years_experience,
       RANK() OVER (PARTITION BY level ORDER BY years_experience DESC)
FROM developers;

*/

WITH CTE AS (SELECT user_id, spend, transaction_date,
ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) 
AS rank FROM transactions)

SELECT user_id,spend,transaction_date FROM CTE WHERE rank = 3;


/*

Q13 : Medium

This is the same question as problem #25 in the SQL Chapter of Ace the Data Science Interview!

Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.

Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of 
total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.

Notes:

Calculate the following percentages:
time spent sending / (Time spent sending + Time spent opening)
Time spent opening / (Time spent sending + Time spent opening)
To avoid integer division in percentages, multiply by 100.0 and not 100.

*/



WITH CTE1 AS (SELECT AB.age_bucket,SUM(A.time_spent) AS open 
FROM activities A,age_breakdown AB
WHERE A.user_id = AB.user_id AND A.activity_type = 'open' GROUP BY AB.age_bucket),

CTE2 AS (SELECT AB.age_bucket, SUM(A.time_spent) AS send 
FROM activities A,age_breakdown AB
WHERE A.user_id = AB.user_id AND A.activity_type = 'send' GROUP BY AB.age_bucket)

SELECT C1.age_bucket,ROUND((100.0*C2.send/(C1.open + C2.send)),2) AS send_perc,
ROUND((100.0*C1.open/(C2.send + C1.open)),2) AS open_perc
FROM CTE1 C1,CTE2 C2 WHERE C1.age_bucket = C2.age_bucket;



with cte as (SELECT *,
(CASE WHEN activity_type='open' then time_spent else 0 END) as t1,
(CASE WHEN activity_type='send' then time_spent else 0 END) as t2
FROM activities a1 join age_breakdown a2
on a1.user_id=a2.user_id where activity_type in ('send','open'))

SELECT age_bucket,round(SUM(t1)*100.0/SUM(t1+t2),2) as open_perc,
round(SUM(t2)*100.0/SUM(t1+t2),2) as send_perc from cte GROUP BY 1

/*

Q14: Medium

Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.

Notes:

A rolling average, also known as a moving average or running mean is a time-series technique that examines trends in data over a specified period of time.
In this case, we want to determine how the tweet count for each user changes over a 3-day period.
Effective April 7th, 2023, the problem statement, solution and hints for this question have been revised.

Concept of Rolling Sum is needed.

OVER, PARTITION BY, CTE, ROWS BETWEEN, PRECEDING, CURRENT ROW

*/


WITH CTE AS
(SELECT user_id, tweet_date,AVG(tweet_count) OVER(PARTITION BY user_id ORDER BY tweet_date
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) 
AS TC FROM tweets)

SELECT user_id, tweet_date, ROUND(TC,2) AS rolling_avg_3d FROM CTE;

/*

Q15 : Medium

This is the same question as problem #12 in the SQL Chapter of Ace the Data Science Interview!

Assume you're given a table containing data on Amazon customers and their spending on products in different category, 
write a query to identify the top two highest-grossing products within each category in the year 2022. The output should include 
the category, product, and total spend.

*/


SELECT category, product, SUM(spend) AS total_spend
FROM product_spend WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product;

--- Now we need to rank within the group, by Sum(Spend)
---  DENSE_RANK() OVER(PARTITION BY category ORDER BY SUM(spend) DESC) AS rankno



WITH CTE AS
(SELECT category, product, SUM(spend) AS total_spend, DENSE_RANK()
OVER(PARTITION BY category ORDER BY SUM(spend) DESC) AS rankno
FROM product_spend WHERE EXTRACT(YEAR FROM transaction_date) = 2022
GROUP BY category, product)

SELECT category, product, total_spend FROM CTE 
WHERE rankno <= 2;


/*

Q16 : Medium

Assume there are three Spotify tables: artists, songs, and global_song_rank, which contain information about the artists, songs, and music charts, respectively.

Write a query to find the top 5 artists 
whose songs appear most frequently in the Top 10 of the global_song_rank table. Display the top 5 artist 
names in ascending order, along with their song appearance ranking.

If two or more artists have the same number of song appearances, they should be assigned the same ranking


*/

WITH CTE AS (SELECT A.artist_id, A.artist_name, COUNT(*) AS cnt
FROM artists A,songs S,global_song_rank GSR
WHERE A.artist_id = S.artist_id AND S.song_id = GSR.song_id AND
GSR.rank <= 10 GROUP BY A.artist_id, A.artist_name ORDER BY cnt DESC),

CTE2 AS (SELECT artist_name, DENSE_RANK() OVER(ORDER BY cnt DESC) AS artist_rank FROM CTE)

SELECT artist_name,artist_rank FROM CTE2 WHERE artist_rank <=5;