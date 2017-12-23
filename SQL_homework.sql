USE sakila;

show create database sakila;
# 1a
SELECT first_name, last_name 
FROM actor;

# 1b
SELECT CONCAT(first_name, ' ' ,last_name) AS 'Actor Name'
FROM actor;

# 2a. You need to find the ID number, first name, and last name of an actor, 
# of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name,last_name
FROM actor
WHERE first_name = 'Joe';

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT CONCAT(first_name, ' ' ,last_name) AS 'Actors with GEN in Last Name'
FROM actor
WHERE last_name LIKE '%GEN%';

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT CONCAT(last_name, ' ' ,first_name) AS 'Actors with LI in Last Name'
FROM actor
WHERE last_name LIKE '%LI%';

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

# 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(20) AFTER first_name;

# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE actor MODIFY middle_name BLOB;

# 3c. Now delete the `middle_name` column.
ALTER TABLE actor drop middle_name;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) 
FROM actor
GROUP BY last_name;

#if (count(*) >= 2, count(*), NULL) AS COUNT
# SELECT * FROM `movies` GROUP BY `category_id`,`year_released` HAVING `category_id` = 8;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*) as Count
FROM actor
GROUP BY last_name
HAVING Count > 1;

# 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, 
# the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO' where first_name = 'GROUCHO' and last_name='WILLIAMS';


SELECT first_name, last_name FROM actor where last_name='WILLIAMS';

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct 
# name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to 
# `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be 
# with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
# (Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = CASE
		WHEN (first_name = 'HARPO' AND last_name ='WILLIAMS') THEN 'GROUCHO'
		WHEN (first_name = 'GROUCHO' AND last_name ='WILLIAMS') THEN 'MUCHO GROUCHO'
		ELSE first_name
		END
WHERE last_name in ('WILLIAMS');

#5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it

SHOW CREATE TABLE address;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the 
# tables `staff` and `address`:
SELECT staff.first_name, staff.last_name, address.address
FROM staff  
INNER JOIN address ON
staff.address_id = address.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables  
# `staff` and `payment`. 
SELECT staff.first_name, staff.last_name, payment.amount, payment_date
FROM staff  
INNER JOIN payment ON
payment.staff_id = staff.staff_id
WHERE payment.payment_date LIKE '%-08-%';

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` 
# and `film`. Use inner join.

SELECT film.title, sum(film_actor.actor_id) as 'Number of actors'
FROM film  
INNER JOIN film_actor ON
film.film_id = film_actor.film_id
GROUP BY film.title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

SELECT film.title as 'Title', sum(inventory.inventory_id) as 'Number of copies'
FROM film  
INNER JOIN inventory ON
film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid 
# by each customer. List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, sum(payment.amount) as 'Total amount paid'
FROM customer  
INNER JOIN payment ON
customer.customer_id = payment.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY customer.last_name ASC;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended 
# consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use 
# subqueries to display the titles of movies starting with the letters `K` and `Q` whose language 
# is English. 

SELECT film.title, language.name
FROM film 
INNER JOIN language ON
film.language_id = language.language_id
WHERE (film.title LIKE 'K%' OR 
	  film.title LIKE 'Q%') AND
      language.name = 'English';

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select film.title, actor.first_name, actor.last_name
from actor
inner join film_actor on
actor.actor_id = film_actor.actor_id
inner join film on 
film_actor.film_id = film.film_id
where film.title = 'ALONE TRIP';


# 7c. You want to run an email marketing campaign in Canada, for which you will need the names 
# and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email, city.city, country.country
FROM customer 
INNER JOIN address ON 
address.address_id = customer.address_id
INNER JOIN city ON
city.city_id = address.city_id
INNER JOIN country ON
city.country_id = country.country_id
WHERE country.country = 'CANADA';

# 7d. Sales have been lagging among young families, and you wish to target all family 
# movies for a promotion. Identify all movies categorized as famiy films.

select film_text.title, category.name as 'Category'
from film_text
inner join film_category on
film_text.film_id = film_category.film_id
inner join category on
category.category_id = film_category.category_id
where category.name = 'Family';

# 7e. Display the most frequently rented movies in descending order.

select film.title, count(rental.rental_id) as 'Rental Count'
from rental
left join inventory on
rental.inventory_id = inventory.inventory_id
left join film on
film.film_id = inventory.film_id
group by film.title
order by count(rental.rental_id) desc;

# 7f. Write a query to display how much business, in dollars, each store brought in.

select inventory.store_id as 'Store', sum(payment.amount) as 'Income'
from rental
left join payment on
payment.rental_id = rental.rental_id
left join inventory on 
rental.inventory_id = inventory.inventory_id
group by inventory.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.

select store.store_id, city.city, country.country
from store
left join address on 
store.address_id = address.address_id
left join city on
city.city_id = address.city_id
left join country on
country.country_id = city.country_id;

# 7h. List the top five genres in gross revenue in descending order. 
# (**Hint**: you may need to use the following tables: 
# category, film_category, inventory, payment, and rental.)

select category.name as GENERES, sum(payment.amount) as 'GROSS REVENUE'
from category
left join film_category on
film_category.category_id = category.category_id
left join inventory on 
film_category.film_id = inventory.film_id
left join rental on
inventory.inventory_id = rental.inventory_id
left join payment on 
payment.rental_id = rental.customer_id
group by category.name
order by sum(payment.amount) desc
limit 5;

# 8a. In your new role as an executive, you would like to have an easy way 
# of viewing the Top five genres by gross revenue. Use the solution from 
# the problem above to create a view. If you haven't solved 7h, you can 
# substitute another query to create a view.

CREATE VIEW TOP_FIVE_GENRES_BY_GROSS_RVENUE AS
select category.name as GENERES, sum(payment.amount) as 'GROSS REVENUE'
from category
left join film_category on
film_category.category_id = category.category_id
left join inventory on 
film_category.film_id = inventory.film_id
left join rental on
inventory.inventory_id = rental.inventory_id
left join payment on 
payment.rental_id = rental.customer_id
group by category.name
order by sum(payment.amount) desc
limit 5;

# 8b. How would you display the view that you created in 8a?
select * from TOP_FIVE_GENRES_BY_GROSS_RVENUE;

# 8c. You find that you no longer need the view `top_five_genres`. Write a 
# query to delete it.
DROP VIEW TOP_FIVE_GENRES_BY_GROSS_RVENUE;
