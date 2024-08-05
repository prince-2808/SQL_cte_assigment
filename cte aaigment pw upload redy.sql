--  First Normal Form (1NF)
--  Identify a table in the Sakila database that violates 1NF. Explain how you would normalize it to achieve 1NF
SELECT 
    *
FROM
    address;
-- Add new columns
ALTER TABLE address
ADD COLUMN street_i VARCHAR(50),
ADD COLUMN street_v VARCHAR(100);

-- Update new columns with split data(left and right)
 UPDATE address
 set street_i=left( address, locate(' ',address ) - 1    ),
       street_v=right( address, length( address  ) -locate(' ', address) );

 
 
-- Verify the data
SELECT address_id, street_i, street_v FROM address;

-- (Optional) Drop the old column
 ALTER TABLE address
 DROP COLUMN address2;
 -- rename the column
 alter table address
 rename column street_i to
 street_code;
 alter table address
 rename column street_v to
 address;
 -- the address table column address change in 1NF 
 
 -- Q2.  Choose a table in Sakila and describe how you would determine whether it is in 2NF. If it violates 2NF, 
-- explain the steps to normalize it
-- ANSWER >>>>>

-- Let’s consider the rental table in the Sakila database to determine whether it is in Second Normal Form (2NF) and, if it violates 2NF, how to normalize it.
-- Determining 2NF
-- A table is in 2NF if:

-- It is in 1NF.
-- All non-key attributes are fully functionally dependent on the primary key.
-- The rental table has a composite primary key consisting of rental_id. To check if it is in 2NF, we need to ensure that all non-key attributes (rental_date, inventory_id, customer_id, return_date, staff_id, last_update) are fully dependent on the primary key.

-- Violation of 2NF
-- If any non-key attribute is dependent on only a part of the composite primary key, the table violates 2NF. In this case, rental_id is a single-column primary key, so we need to check if any non-key attribute is dependent on something other than rental_id.

-- Normalizing to Achieve 2NF
-- If we find that some attributes are dependent on inventory_id or customer_id rather than rental_id, we need to create separate tables to remove partial dependencies.

-- Step 1: Identify Partial Dependencies
-- Let’s assume inventory_id and customer_id have partial dependencies. For example, inventory_id might have attributes like film_id and store_id that are dependent on it.

-- Step 2: Create New Tables
-- Create an inventory table to store details related to inventory_id:
-- SQL

CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY,
    film_id INT,
    store_id INT,
    last_update TIMESTAMP
);

-- Create a customer table to store details related to customer_id:
-- SQL

CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    store_id INT,
    first_name VARCHAR(45),
    last_name VARCHAR(45),
    email VARCHAR(50),
    address_id INT,
    active BOOLEAN,
    create_date DATE,
    last_update TIMESTAMP
);

-- Step 3: Update the rental Table
-- Remove the attributes that are now in the inventory and customer tables from the rental table:



CREATE TABLE rental (
    rental_id INT PRIMARY KEY,
    rental_date TIMESTAMP,
    inventory_id INT,
    customer_id INT,
    return_date TIMESTAMP,
    staff_id INT,
    last_update TIMESTAMP,
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
 
 -- Q.3  Identify a table in Sakila that violates 3NF. Describe the transitive dependencies present and outline the 
-- steps to normalize the table to 3NF
--  ANSWER>>>>>>>>

--  Let’s consider the film table in the Sakila database to identify a violation of Third Normal Form (3NF).
--  Violation of 3NF
-- A table is in 3NF if:

-- It is in 2NF.
-- It has no transitive dependencies (i.e., non-key attributes are not dependent on other non-key attributes).
-- In the film table, language_id and original_language_id are likely to have transitive dependencies because they refer to the language table, which contains name and last_update.

-- Transitive Dependencies
-- language_id -> name (language name)
-- original_language_id -> name (original language name)
-- Steps to Normalize to 3NF
-- Create a language table to store language details:
-- SQL

CREATE TABLE language (
    language_id INT PRIMARY KEY,
    name VARCHAR(20),
    last_update TIMESTAMP
);

-- Remove name from the film table and use language_id and original_language_id as foreign keys:
-- SQL

-- ALTER TABLE film
-- DROP COLUMN name;

-- Update the film table to reference the language table:
-- SQL

ALTER TABLE film
ADD CONSTRAINT fk_language
FOREIGN KEY (language_id) REFERENCES language(language_id),
ADD CONSTRAINT fk_original_language
FOREIGN KEY (original_language_id) REFERENCES language(language_id);
 
 -- Q4  Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have 
-- acted in from the  actor and  film_actor tables
 
 with afc as
 (SELECT 
    COUNT(fa.film_id) AS total_film, a.first_name, a.last_name,a.actor_id
FROM
    actor AS a
        JOIN
    film_actor AS fa ON a.actor_id = fa.actor_id
GROUP BY a.first_name , last_name ,actor_id)
select first_name,last_name,total_film from afc order by total_film desc;
-- Q.5 Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the 
-- table in Sakila
ALTER TABLE category ADD COLUMN parent_category_id INT NULL;
UPDATE category SET parent_category_id = NULL WHERE category_id = 1; -- Top-level category
UPDATE category SET parent_category_id = 1 WHERE category_id = 2; -- Subcategory of category 1
UPDATE category SET parent_category_id = 1 WHERE category_id = 3; -- Subcategory of category 1
WITH RECURSIVE CategoryHierarchy AS (
    SELECT 
        c.category_id,
        c.name AS category_name,
        NULL AS parent_category_id,
        c.name AS hierarchy_path
    FROM 
        category c
    WHERE 
        c.parent_category_id IS NULL
    
    UNION ALL
    
    SELECT 
        c.category_id,
        c.name AS category_name,
        ch.category_id AS parent_category_id,
        CONCAT(ch.hierarchy_path, ' > ', c.name) AS hierarchy_path
    FROM 
        category c
    INNER JOIN 
        CategoryHierarchy ch ON c.parent_category_id = ch.category_id
)
SELECT 
    category_id,
    category_name,
    parent_category_id,
    hierarchy_path
FROM 
    CategoryHierarchy
ORDER BY 
    hierarchy_path;
    ALTER TABLE category MODIFY COLUMN parent_category_id INT;

-- Create a CTE that combines information from the film and language table to display the 
-- film title,language,name and rantal rate  
with mycte as(SELECT 
     f.title, f.language_id, f.rental_rate, l.name as lang_name
FROM
    film f
         JOIN
    language l ON f.language_id = l.language_id)
    SELECT 
    title, lang_name, rental_rate
FROM
    mycte ;
    
--  Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from 
-- the customer and payment table
with mycte as 
(select c.customer_id,c.first_name,c.last_name,sum(p.amount) as sum_of_paymnt from customer as c
join payment p 
on c.customer_id= p.customer_id
group by c.customer_id,c.first_name,c.last_name)
select concat(first_name,'  ',last_name)as customer_name, sum_of_paymnt from mycte
order by sum_of_paymnt desc;

--  Utilize a CTE with a window function to rank films based on their rental duration from the  film table.
with my_cte as(select film_id, title,rental_duration ,
 dense_rank() over(order by rental_duration desc) as ranking
 from film)
 select ranking, film_id, rental_duration, title from my_cte order by ranking ;
 
 -- Create a CTE to list customers who have made more than two rentals, and then join this CTE with the 
 -- customer table to retrieve additional customer details
 with my_cte as 
 (select  c.customer_id,c.first_name,c.last_name,  count(r.rental_id ) 
     as total_rental_count from customer c
 join rental r on c.customer_id= r.customer_id
 group by c.customer_id, c.first_name,c.last_name
 order by total_rental_count and c.customer_id )
 select * from my_cte where total_rental_count > 2;
 
 --  Write a query using a CTE to find the total number of rentals made each month, considering the  
-- from the rental table
with my_cte as
 (select count(rental_id) as total_rental, monthname(rental_date) as months, year(rental_date) as years
 from rental 
group by months , years)
select * from my_cte; 

--  Use a CTE to pivot the data from the  payment table to display the total payments made by each customer in 
-- separate columns for different payment methods
SELECT 
    p.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS name_cus,
    SUM(CASE
        WHEN payment_mode = 'upi' THEN amount
        ELSE 0
    END) AS UPI_payment,
    SUM(CASE
        WHEN payment_mode = 'cash' THEN amount
        ELSE 0
    END) AS cash_payment,
    SUM(CASE
        WHEN payment_mode = 'credit card' THEN amount
        ELSE 0
    END) AS credit_card_payment,
    SUM(CASE
        WHEN payment_mode = 'online' THEN amount
        ELSE 0
    END) AS online_payment
FROM
    payment p
        JOIN
    customer c ON p.customer_id = c.customer_id
GROUP BY customer_id , name_cus;

-- Create a CTE to generate a report showing pairs of actors who have appeared in the same film together, 
-- using the  film_actor table
SET @@cte_max_recursion_depth = 2001;  -- or any higher value as needed

WITH ActorPairs AS (
    SELECT 
        fa1.actor_id AS actor1_id,
        fa2.actor_id AS actor2_id,
        f.title AS film_title
    FROM 
        film_actor fa1
    INNER JOIN 
        film_actor fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id
    INNER JOIN 
        film f ON fa1.film_id = f.film_id
)
SELECT 
    a1.first_name AS actor1_first_name,
    a1.last_name AS actor1_last_name,
    a2.first_name AS actor2_first_name,
    a2.last_name AS actor2_last_name,
    film_title
FROM 
    ActorPairs ap
INNER JOIN 
    actor a1 ON ap.actor1_id = a1.actor_id
INNER JOIN 
    actor a2 ON ap.actor2_id = a2.actor_id
ORDER BY 
    film_title, actor1_first_name, actor2_first_name;

--  Implement a recursive CTE to find all employees in the staff table who report to a specific manager, considering the 
-- reports_to column.

WITH RECURSIVE EmployeeHierarchy AS (
    -- Anchor member: Select the manager's store
    SELECT 
        s.staff_id,
        s.first_name,
        s.last_name
    FROM 
        staff s
    INNER JOIN 
        store st ON s.store_id = st.store_id
       -- Replace <manager_id> with the actual manager's ID
    
    UNION ALL
    
    -- Recursive member: Select employees who report to the manager or to any employee in the hierarchy
    SELECT 
        s.staff_id,
        s.first_name,
        s.last_name
    FROM 
        staff s
    INNER JOIN 
        EmployeeHierarchy eh ON s.staff_id = eh.staff_id
)
SELECT 
    staff_id,
    first_name,
    last_name
FROM 
    EmployeeHierarchy
ORDER BY 
     staff_id;













