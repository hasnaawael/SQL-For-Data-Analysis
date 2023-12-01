--  select from tables
SELECT actor_id FROM sakila.actor;
SELECT count(actor_id) FROM sakila.actor; -- Num Of Rows
SELECT DISTINCT actor_id FROM sakila.actor; -- Non-recurring values
SELECT actor_id, first_name FROM sakila.actor;
USE sakila; -- For Using specific Data
SELECT actor_id, first_name FROM actor;
SELECT actor_id, first_name FROM actor LIMIT 5;
SELECT actor_id, first_name FROM actor LIMIT 5, 10; -- Start From 5 and ADD 10
SELECT actor_id, first_name, 'dummy text' FROM actor LIMIT 5; -- Add New Column
SELECT actor_id, first_name, curdate() FROM actor LIMIT 5; -- Add Column Contain Current Date
SELECT * FROM actor; -- Select All

-- table stmt
TABLE actor; -- similar to SELECT * FROM actor;

SELECT 
    actor_id  AS "Actor ID",
    CONCAT(LOWER(first_name), ' ', LOWER(last_name)) AS "Actor Full Name",
    last_update AS "Last updated"
FROM
    actor; -- use built-in functions

-- sorting 
SELECT actor_id, first_name, last_name, last_update FROM actor ORDER BY first_name;
SELECT actor_id, first_name, last_name, last_update FROM actor ORDER BY last_name;
SELECT rental_id, rental_date FROM rental ORDER BY rental_date;
SELECT actor_id, first_name, last_name, last_update FROM actor ORDER BY first_name, last_name; -- If Fname repeatedو arrange it by Lname

-- union
(SELECT actor_id, first_name FROM actor LIMIT 5, 10)
UNION 
(SELECT actor_id, first_name FROM actor LIMIT 50 , 10);

-- where clause
SELECT * FROM film_text WHERE film_id < 10;
SELECT * FROM film_text WHERE length(title) < 10;
SELECT * FROM film_text WHERE title LIKE "Ar%";
SELECT * FROM film_text WHERE title LIKE "Ar%" and film_id > 38;
SELECT * FROM film_text WHERE locate("drama", description);

-- prepare and execute
PREPARE sql_stmt FROM 'SELECT * FROM film_text WHERE title LIKE "Ar%" and film_id > ?';
SET @id := 38;
EXECUTE sql_stmt USING @id; -- Finds "؟" and places it by @id

PREPARE sql_stmt FROM 'SELECT * FROM film_text WHERE title LIKE ? and film_id > ?';
SET @text := "Ar%";
SET @id := 38;
EXECUTE sql_stmt USING @text, @id;

DROP PREPARE sql_stmt;
DEALLOCATE PREPARE sql_stmt;

-- group by
SELECT customer_id, count(rental_id) FROM rental GROUP BY customer_id;
SELECT customer_id, count(rental_id) FROM rental GROUP BY customer_id ORDER BY customer_id DESC;
SELECT customer_id, count(rental_id) FROM rental GROUP BY customer_id ORDER BY count(rental_id) DESC;
SELECT customer_id, sum(amount) FROM payment GROUP BY customer_id ORDER BY sum(amount) DESC;

-- having
SELECT customer_id, sum(amount) FROM payment GROUP BY customer_id HAVING sum(amount) > 150 ORDER BY sum(amount) DESC; 

-- joins
SELECT film_category.film_id, category.category_id, category.name FROM category INNER JOIN film_category
ON film_category.category_id  = category.category_id;

SELECT fc.film_id, c.category_id, c.name FROM category AS c INNER JOIN film_category AS fc
ON fc.category_id  = c.category_id;

SELECT fc.film_id, c.category_id, c.name FROM category AS c
INNER JOIN film_category AS fc
USING (category_id);

SELECT fc.film_id, c.category_id, c.name FROM category AS c LEFT JOIN film_category AS fc
USING (category_id);

SELECT fc.film_id, c.category_id, c.name FROM category AS c RIGHT JOIN film_category AS fc
USING (category_id);

-- join 3 tables
SELECT fc.film_id, f.title, c.category_id, c.name FROM category AS c INNER JOIN film_category AS fc
ON fc.category_id  = c.category_id
INNER JOIN film AS f
ON f.film_id = fc.film_id;

SELECT fc.film_id, f.title AS "Film Name", c.name AS "Genre" FROM category AS c INNER JOIN film_category AS fc
ON fc.category_id  = c.category_id
INNER JOIN film AS f
ON f.film_id = fc.film_id;

-- views
CREATE VIEW vw_file_genre
AS
SELECT fc.film_id, f.title AS "Film Name", c.name AS "Genre" FROM category AS c INNER JOIN film_category AS fc
ON fc.category_id  = c.category_id
INNER JOIN film AS f
ON f.film_id = fc.film_id;