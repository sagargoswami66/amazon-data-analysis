use demodb ;

create table amazon_cleaned(
product_id varchar(60),
product_name  varchar(1202),
category varchar(255),
discounted_price decimal(10,2),
actual_price decimal(10,2),
discount_percentage decimal(10,2),
rating decimal(10,2),
rating_count int,
user_id varchar(255),
user_name varchar(255),
review_id varchar(255)
) ;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/amazon_cleaned.csv'
INTO TABLE amazon_cleaned
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Top 10 highest rated products 

SELECT
    product_id,
    product_name,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(rating_count) AS total_reviews
FROM amazon_cleaned
GROUP BY product_id, product_name
HAVING SUM(rating_count) >= 100
ORDER BY avg_rating DESC
LIMIT 10;

-- Customers who are most active based on the number of reviews written.

SELECT
    user_id,
    user_name,
    COUNT(review_id) AS total_reviews_written
FROM amazon_cleaned
GROUP BY user_id, user_name
ORDER BY total_reviews_written DESC
LIMIT 10;

-- Top 10 products with the highest number of customer reviews.

SELECT 
	product_name,
    product_id,
    SUM(rating_count) AS total_reviews
FROM amazon_cleaned 
GROUP BY product_name, product_id
ORDER BY total_reviews DESC
LIMIT 10 ;    

-- Does discount percentage affect product ratings?

SELECT
    discount_percentage,
    ROUND(AVG(rating), 2) AS avg_rating
FROM amazon_cleaned
GROUP BY discount_percentage
ORDER BY discount_percentage ;

-- Top 3 highest rated products in each category.

SELECT *
FROM (
    SELECT
        category,
        product_id,
        product_name,
        ROUND(AVG(rating), 2) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY AVG(rating) DESC) AS rn
    FROM amazon_cleaned
    GROUP BY category, product_id, product_name
) ranked_products
WHERE rn <= 3;

-- Which categories have the highest average ratings and total review volume?

SELECT
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(rating_count) AS total_reviews
FROM amazon_cleaned
GROUP BY category
ORDER BY avg_rating DESC, total_reviews DESC;

-- Products with high review counts but low ratings.

SELECT
    product_id,
    product_name,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(rating_count) AS total_reviews
FROM amazon_cleaned
GROUP BY product_id, product_name
HAVING
    SUM(rating_count) >= 50000
    AND AVG(rating) < 3.5
ORDER BY total_reviews DESC;

-- Products with high ratings but low review counts (hidden gems).

SELECT
    product_id,
    product_name,
    ROUND(AVG(rating), 2) AS avg_rating,
    SUM(rating_count) AS total_reviews
FROM amazon_cleaned
GROUP BY product_id, product_name
HAVING
    AVG(rating) >= 4.5
    AND SUM(rating_count) < 10000
ORDER BY avg_rating DESC;




















