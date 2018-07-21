use sakila;

### Create these queries to develop greater fluency in SQL, an important database language.

-- * 1a. You need a list of all the actors who have Display the first and last names of all actors from the table `actor`. 

select first_name, last_name from actor;

-- ** 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 

SELECT CONCAT(UPPER(first_name), " ", UPPER(last_name)) as "Actor Name"
FROM actor;

-- ** 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
 select actor_id, first_name, last_name from actor where first_name='Joe';
 
-- * 2b. Find all actors whose last name contain the letters `GEN`:
  	SELECT * FROM actor WHERE last_name LIKE '%gen%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

SELECT last_name,first_name FROM actor WHERE last_name LIKE '%li%' ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');
-- * 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
alter table actor add column middle_name varchar(30) after first_name;
  	
-- * 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor MODIFY middle_name BLOB;
-- * 3c. Now delete the `middle_name` column.
ALTER TABLE actor DROP middle_name;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Number of Actors' 
FROM actor
GROUP BY last_name;
 	
-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select first_name, last_name, count(last_name) from actor group by last_name having count(last_name)>1;
  	
-- * 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
  	
    UPDATE actor SET first_name = 'HARPO' 
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)
set sql_safe_updates = 0;
Update actor set first_name = 'GROUCHO' where first_name = 'HARPO';

--  5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
select * from information_schema.columns where table_name = 'sakila.address';
-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select first_name,last_name, address from staff s inner join  address a on a.address_id = s.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`. 
  	SELECT s.first_name, s.last_name, SUM(p.amount) as "Total Rung Up", p.payment_date
FROM staff s
INNER JOIN payment p 
ON s.staff_id = p.staff_id where p.payment_date like '2005-08-%'
GROUP BY s.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title, f.film_id, count(fa.actor_id) from film f inner join film_actor fa on 
f.film_id = fa.film_id group by f.film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title, COUNT(i.film_id) as "No of Fims in Inv"
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
GROUP BY f.film_id
HAVING f.title = "Hunchback Impossible";

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command,
-- list the total paid by each customer. 
-- List the customers alphabetically by last name:
 SELECT c.first_name, c.last_name, SUM(p.amount) as "Total " 
FROM customer c
INNER JOIN payment p 
ON p.customer_id = c.customer_id 
GROUP BY c.customer_id order by c.last_name ASC;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also
 -- soared in popularity. Use subqueries to display the titles of movies starting with 
-- the letters `K` and `Q` whose language is English. 
SELECT title FROM film where (title LIKE "K%") OR (title LIKE "Q%")
and language_id IN
	(SELECT language_id FROM language
	WHERE name = "English");

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
   select first_name, last_name from actor where actor_id in(select actor_id from film_actor 
   where film_id in (select film_id from film where title = 'Alone Trip'));
-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
select c.first_name, c.last_name, c.email, co.country
from customer c join address a on a.address_id = c.address_id
join city ci on ci.city_id = a.city_id
join country co on co.country_id= ci.country_id
where co.country ='CANADA';

-- * 7d. Sales have been lagging among young families, and 
-- you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title from film where film_id in 
 (select film_id from film_category where catgory_id in
 ( select category_id from category where name ='Family'));

-- * 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) from film f , rental r , inventory i where
f.film_id = i.film_id and i.inventory_id = r.inventory_id group by f.title ORDER BY COUNT(r.rental_id) DESC;
  	
-- * 7f. Write a query to display how much business, in dollars, each store brought in.
  SELECT s.store_id, sum(amount) FROM store s
 JOIN customer c
ON s.store_id = c.store_id
 JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY s.store_id;
-- * 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id, ci.city, co.country from store s, city ci, country co, address a where 
s.address_id = a.address_id and a.city_id = ci.city_id and ci.country_id = co.country_id;
  	
-- * 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select cat.name, sum(p.amount) from category cat, payment p, inventory i, rental r, film_category fc
where cat.category_id=fc.category_id and fc.film_id = i.film_id 
and i.inventory_id = r.inventory_id and r.rental_id = p.rental_id group by cat.name;
  	
-- 8a. In your new role as an executive, you would like to have an easy way of 
-- viewing the Top five genres by gross revenue. Use the solution from the problem 
-- above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_5_by_genre AS
select cat.name, sum(p.amount) as "Revenue" from category cat, payment p, inventory i, rental r, film_category fc
where cat.category_id=fc.category_id and fc.film_id = i.film_id 
and i.inventory_id = r.inventory_id and r.rental_id = p.rental_id group by cat.name ORDER BY amount DESC LIMIT 5;
  	
-- * 8b. How would you display the view that you created in 8a?
select * from top_5_by_genre;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

DROP VIEW top_5_by_genre;

