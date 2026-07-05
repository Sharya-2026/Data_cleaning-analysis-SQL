


DROP TABLE IF EXISTS REVIEWS;
create table reviews(
listing_id INT ,
id INT ,
date DATE ,
reviewer_id INT,
reviewer_name VARCHAR(30)

);
SELECT * FROM REVIEWS;

DROP TABLE IF EXISTS LISTINGS;
CREATE TABLE LISTINGS(
id INT,
name	VARCHAR(50),
host_id INT,
host_name	VARCHAR(35),
neighbourhood VARCHAR(25),
latitude FLOAT,
longitude FLOAT,
room_type	VARCHAR(25),
price	INT,
minimum_nights INT,
number_of_reviews INT,
reviews_per_month FLOAT,
calculated_host_listings_count	INT,
availability_365 INT,
number_of_reviews_ltm INT

);
SELECT * FROM LISTINGS;
drop table if exists CALENDAR;
CREATE TABLE CALENDAR(
listing_id	INT ,
date TEXT,
price TEXT,
minimum_nights INT,
maximum_nights INT,
PRIMARY KEY(listing_id, date)

);

SELECT * FROM CALENDAR
LIMIT 10;

--market size
SELECT COUNT(*) AS total_listings
FROM listings;

--AVG NIGHTLY PRICE
SELECT ROUND(AVG(price),2)
from listings;

--TOTAL HOST
SELECT COUNT(DISTINCT host_id)
FROM listings;

--ROOM-TYPE DISTRIBUTION
SELECT room_type,
       COUNT(*) AS total
FROM listings
GROUP BY room_type
ORDER BY total DESC;

--AVG PRICE BY ROOM-TYPE
SELECT room_type,
       ROUND(AVG(price),2)
FROM listings
GROUP BY room_type;


--ROOM TYPE REVENUE
SELECT
    room_type,
    SUM(
      price*(365-availability_365)
    ) AS revenue
FROM listings
GROUP BY room_type;
--TOP 10 EXPENSIVE LISTINGS
SELECT id,
       name,
       price,
FROM listings
ORDER BY price DESC
LIMIT 10;

--OCCUPANCY ANALYSIS
SELECT
    neighbourhood,
    AVG(365 - availability_365) AS booked_days
FROM listings
GROUP BY neighbourhood;
--TOP NEIGHBOURHOOD
SELECT neighbourhood,
       COUNT(*) AS listings
FROM listings
GROUP BY neighbourhood
ORDER BY listings DESC
LIMIT 10;

--LOW PERFORMANCE NEIGHBOURHOOD
SELECT neighbourhood,
       COUNT(*) AS listings
FROM listings
GROUP BY neighbourhood
ORDER BY listings ASC
LIMIT 10;



--NEIGHBOURHOOD BY AVG PRICE
SELECT neighbourhood,
       AVG(price) avg_price,
       RANK() OVER(
       ORDER BY AVG(price) DESC
       ) AS rank_no
FROM listings
GROUP BY neighbourhood;


--LISTINGS ABOVE AVG PRICE
SELECT *
FROM listings
WHERE price >
(
SELECT AVG(price)
FROM listings
);

--PREMIUM LISTING
SELECT *
FROM listings
WHERE price >
(
SELECT AVG(price)
FROM listings
)
AND number_of_reviews >
(
SELECT AVG(number_of_reviews)
FROM listings
);

--MOST REVIEWED PROPERTIES
SELECT id,
       name,
       number_of_reviews
FROM listings
ORDER BY number_of_reviews DESC
LIMIT 10;

--LISTING WITH NO REVIEWS
SELECT
    l.id,
    l.name
FROM Listings l
LEFT JOIN Reviews r
ON l.id = r.listing_id
WHERE r.id IS NULL;


--TOP REVIEWS PER LISTING
SELECT
    l.id,
    l.name,
    COUNT(r.id) AS total_reviews
FROM Listings l
JOIN Reviews r
ON l.id = r.listing_id
GROUP BY l.id,l.name
ORDER BY total_reviews DESC;

--BEST PERFORMING HOST
SELECT host_name,
       COUNT(*) AS properties,
       SUM(number_of_reviews) AS reviews
FROM listings
GROUP BY host_name
ORDER BY reviews DESC
LIMIT 10;

--LOW PERFORMANCE HOST
SELECT host_name,
       COUNT(*) AS properties,
       SUM(number_of_reviews) AS reviews
FROM listings
GROUP BY host_name
ORDER BY reviews ASC
LIMIT 10;

--TOP HOSTS IN EACH NEIGHBOURHOOD
WITH host_stats AS
(
SELECT neighbourhood,
       host_name,
       COUNT(*) properties,
       RANK() OVER(
       PARTITION BY neighbourhood
       ORDER BY COUNT(*) DESC
       ) rnk
FROM listings
GROUP BY neighbourhood,host_name
)

SELECT *
FROM host_stats
WHERE rnk = 1;

--REVENUE ANALYSIS
SELECT
    neighbourhood,
    SUM(
       price * (365 - availability_365)
    ) AS estimated_revenue
FROM listings
GROUP BY neighbourhood
ORDER BY estimated_revenue DESC;
--HOST PORTFOLIO ANALYSIS
SELECT
    host_name,
    COUNT(*) AS total_properties
FROM Listings
GROUP BY host_name
ORDER BY total_properties DESC;

--NEIGHBOURHOOD REVENUE ANALYSIS
SELECT
    l.neighbourhood,
    SUM(l.price) AS total_price
FROM Listings l
GROUP BY l.neighbourhood
ORDER BY total_price DESC;

--TOP 3 MOST EXPENSIVE LISTING IN EACH NEIGHNOURHOOD
WITH RankedListings AS
(
    SELECT
        neighbourhood,
        name,
        price,
        RANK() OVER(
            PARTITION BY neighbourhood
            ORDER BY price DESC
        ) AS price_rank
    FROM Listings
)

SELECT *
FROM RankedListings
WHERE price_rank <= 3;

-- REVENUE RANKING OF EACH HOST
WITH HostRevenue AS
(
    SELECT
        host_name,
        SUM(
            price * (365 - availability_365)
        ) AS estimated_revenue
    FROM Listings
    GROUP BY host_name
)

SELECT
    host_name,
    estimated_revenue,

    DENSE_RANK() OVER(
        ORDER BY estimated_revenue DESC
    ) AS revenue_rank

FROM HostRevenue;

