USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT table_name, table_rows -- Finding the total number of rows in each table of our DB imdb
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb';







-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT count(*) FROM movie -- checking for count of null values where Title is null or ''
WHERE title IS NULL OR title = '';

SELECT count(*) FROM movie -- checking for count of null values where Year is null or ''
WHERE year IS NULL OR year = '';

SELECT count(*) FROM movie -- checking for count of null values where date_published is null
WHERE date_published IS NULL;

SELECT count(*) FROM movie -- checking for count of null values where duration is null
WHERE duration IS NULL; 

SELECT count(*) FROM movie -- checking for count of null values where country is null or ''
WHERE country IS NULL OR country=''; -- 20 null values found

SELECT count(*) FROM movie -- checking for count of null values where worlwide_gross_income is null or ''
WHERE worlwide_gross_income IS NULL OR worlwide_gross_income=''; -- 3724 null values found

SELECT count(*) FROM movie -- checking for count of null values where languages is null or ''
WHERE languages IS NULL OR languages=''; -- 194 null values found

SELECT count(*) FROM movie -- checking for count of null values where languages is null or ''
WHERE production_company IS NULL OR production_company=''; -- 528 null values found







-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Needs discussion
SELECT year as Year,  -- solution to first part of the question
		count(distinct id) as number_of_movies -- output not matching with the sample output above
FROM movie 
group by year;

SELECT month(date_published) as month_num,
		count(distinct id) as number_of_movies
FROM movie
group by month(date_published)
order by month_num;  -- output not matching with the sample output above





/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

-- Needs discussion

with USA_Ind  -- finding how many movies produced in USA or India in 2019
as            
(
SELECT *
FROM movie
WHERE country regexp 'USA' OR country regexp 'India'
)
SELECT count(distinct id) as count_of_movies_2019_for_USA_or_India
FROM USA_Ind
WHERE year=2019;






/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT distinct genre  -- finding the unique or distinct list of genre
FROM genre;








/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT count(distinct id) as num_of_movies,  -- count of distinct movie ids per genre
		genre
FROM genre as g
left join movie as m    -- joining with genre with movies. We are using left join because we want to retain all genres from genre dataset
ON g.movie_id=m.id
group by genre
order by num_of_movies desc -- ordering grenres by count of movies and then choosing the to
limit 1;                     -- Drama genre has the most amount of movies produced










/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

with Movies_with_1_genre
as
(
SELECT id,
		title,
		count(genre) as num_of_genres  -- count of genres a movie has
FROM genre as g
inner join movie as m  -- joining with genre with movies
ON g.movie_id=m.id
group by id
having num_of_genres=1   -- filtering movies that have only 1 genre
)
SELECT count(distinct id) as 'count of movies with 1 genre'
FROM Movies_with_1_genre;   -- 3289 mvies have only 1 genre






/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with movies_with_1_genre
as
(
SELECT id,
		title,
		count(genre) as num_of_genres,   -- count of genres a movie has
        genre,
        duration
FROM genre as g
inner join movie as m  -- joining with genre with movies
ON g.movie_id=m.id
group by id
having num_of_genres=1  -- selecting movies with only 1 genre
)
SELECT genre,
		avg(duration) as avg_duration
FROM movies_with_1_genre
group by genre;








/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT genre,
		count(distinct id) as movie_count,  -- count of distinct movie ids per genre
        RANK() OVER(order by count(distinct id) desc) as genre_rank -- ranking each row by count of distinct movie ids or movie_count 
FROM genre as g
left join movie as m    -- joining with genre with movies. We are using left join because we want to retain all genres from genre dataset
ON g.movie_id=m.id
group by genre; -- thriller genre is 3rd ranked in terms of movie produced   









/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT min(avg_rating) as min_avg_rating,
		max(avg_rating) as max_avg_rating,
        min(total_votes) as min_total_votes,
        max(total_votes) as max_total_votes,
        min(median_rating) as min_median_rating,
        max(median_rating) as max_median_rating
FROM ratings;   /* the minimum and maximum values in each column of the ratings table are in the expected range. This implies there are no outliers in the table. */




    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

with ratings_ranked
as
(
SELECT title,
		avg_rating,
        RANK() OVER(window_rating) as movie_rank -- ranking movies by avg_rating
FROM ratings as r
INNER JOIN movie as m   -- joining ratings and movies tables
ON r.movie_id= m.id
WINDOW window_rating AS (order by avg_rating DESC) -- creating a window for ranking movies by avg_rating
)
SELECT * 
FROM ratings_ranked
WHERE movie_rank<=10;  -- SELECTING movies upto rank 10







/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT median_rating,
		count(distinct id) as movie_count -- finding movies count for each rating
FROM ratings as r 
inner join movie as m -- joining ratings and movies tables
ON r.movie_id= m.id
group by median_rating  -- grouping by rating
order by movie_count DESC;  -- movies with median rating 7 are the highest in number









/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

with hit_movies_list   -- finding all hit movies and their production companies that have avg_rating higher than 8
as
(
SELECT production_company,   
		id,
        title,
        avg_rating
FROM movie as m   
INNER JOIN ratings as r      -- joining movies and ratings tables
ON m.id = r.movie_id
WHERE avg_rating>8    -- a movie is considered a hit if it has an avg_rating>8
)
SELECT production_company,
		count(distinct id) as movie_count,      -- count of hit movies produced by each production house
        RANK() OVER(order by count(distinct id) DESC) as prod_company_rank  -- ranking production companies by the number of hit movies they produced
FROM hit_movies_list
group by production_company
order by movie_count DESC;               -- ordering by count of hit movies produced by each production house
-- Dream Warrior Pictures or National Theatre are the top production houses who produced the most number of hit movies

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with movies_usa
as
(                      
SELECT id,                          -- filters all movies released in March 2017 in USA and total votes greater than 1000
		year,
        date_published,
        country,
        genre,
        total_votes
FROM movie as m
INNER JOIN genre as g                   
ON m.id= g.movie_id                      -- joining movie and genre tables
	INNER JOIN ratings as r               -- now joining with ratings table
    ON m.id= r.movie_id
WHERE year= 2017 and month(date_published)=3 and country regexp 'USA' and total_votes>1000
)
SELECT genre,
		count(id) as movie_count          -- count of movies per genre
FROM movies_usa
group by genre
order by movie_count desc;              -- Drama genre has the highest number of movies produced i.e. 24




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

-- needs discussion on whether to group by genre at the last part or not
SELECT title,
		avg_rating,
        genre
FROM movie as m
INNER JOIN genre as g                   
ON m.id= g.movie_id                      -- joining movie and genre tables
	INNER JOIN ratings as r               -- now joining with ratings table
    ON m.id= r.movie_id
WHERE title regexp '^The' and avg_rating>8        -- filtering movies that start with 'The' and has average rating > 8
order by genre;             -- ordering by genre







-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT count(distinct id) as movie_count     -- count of movies
FROM movie as m 
INNER JOIN ratings as r                   -- joining movies and ratings tables
ON m.id= r.movie_id
WHERE (date_published between '2018-04-01' and '2019-04-01') and median_rating=8  -- filtering for movies released between 1 April 2018 and 1 April 2019 that were given a median rating of 8 
order by date_published;                   -- 361 movies released between 1 April 2018 and 1 April 2019 were given a median rating of 8 
        






-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT sum(total_votes) as votes_count     -- count of German movies
FROM movie as m 
INNER JOIN ratings as r                   -- joining movies and ratings tables
ON m.id= r.movie_id
WHERE country regexp 'Germany';          -- 2026223 total votes for German movies. 

SELECT sum(total_votes) as votes_count     -- count of Italian movies
FROM movie as m 
INNER JOIN ratings as r                   -- joining movies and ratings tables
ON m.id= r.movie_id
WHERE country regexp 'Italy';             -- 703024 total votes for Italian movies. So Germany movies do get more votes than Italian movies



-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


SELECT count(*) as name_nulls      -- checking null values in name column
FROM names
WHERE name IS NULL;

SELECT count(*) as height_nulls     -- checking null values in height column
FROM names
WHERE height IS NULL;

SELECT count(*) as date_of_birth_nulls    -- checking null values in date_of_birth column
FROM names
WHERE date_of_birth IS NULL;

SELECT count(*) as known_for_moviesh_nulls
FROM names
WHERE known_for_movies IS NULL;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

with directors_of_top_3_genres            -- main code
as
(
SELECT n.name as director_name,
		d.name_id,
        d.movie_id,
		g.genre
FROM director_mapping as d
INNER JOIN names as n               -- joining names table to get the director names
ON d.name_id= n.id
	INNER JOIN ratings as r         -- joining ratings table to get avg rating values
	ON d.movie_id= r.movie_id
		INNER JOIN genre as g       -- joining genre table to get the genres
		ON d.movie_id= g.movie_id
where avg_rating>8 and (genre='Drama' or genre='Comedy' or genre='Thriller')  -- filtering movies by avg_rating>8 and genre= 'Drama' or 'Comedy' or 'Thriller' since we already know from our previous queries that these 3 are the top 3 genres in terms of number of movies produced
order by name
)
SELECT director_name,
		count(distinct movie_id) as movie_count        -- movie count
FROM directors_of_top_3_genres
group by director_name
order by movie_count DESC               -- selecting the top 3 directors from the top  3 genres
limit 3;                            -- Marianne Elliott, James Mangold and Zoya Akhtar are the top 3 directors





/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


with actors
as(                                     -- finding all actors whose movies that have median rating higher than or equal to 8
SELECT n.name as actor_name,
		rm.name_id,
		rm.movie_id,
        r.median_rating
FROM role_mapping as rm
INNER JOIN names as n        -- joinig role_mapping with names table to get the names of the actors
ON rm.name_id= n.id
	INNER JOIN ratings as r     -- joining ratings table as well to get the median rating values
	ON rm.movie_id= r.movie_id
WHERE category= 'actor' and median_rating>=8   -- filtering by all actors whose movies that have median rating higher than or equal to 8
)
SELECT actor_name,
		count(distinct movie_id) as movie_count      -- movie count
FROM actors
group by actor_name
order by movie_count desc         -- selecting the top 2 actors who made the most movies with median rating >=8
limit 2;                                -- Mammootty and  Mohanlal are the top 2 actors



/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

with prod_houses_ranked
as
(                                                  -- ranking production houses by the total votes received
SELECT m.production_company,
		sum(r.total_votes) as votes_count,            -- sum of total votes per production house
        row_number() OVER(ORDER BY sum(r.total_votes) DESC) as prod_comp_rank  -- rank of each production house in terms of total votes received
FROM movie as m
INNER JOIN ratings as r                        -- joining ratings table to get the total votes
ON m.id= r.movie_id
group by production_company                     -- grouping by production house 
order by votes_count DESC                        -- ordering by total votes received
)
SELECT * 
FROM prod_houses_ranked
WHERE prod_comp_rank<=3;                         -- selecting the top 3 production houses in terms of total votes received

                                            -- MARVEL STUDIOS are the top ranked production house





/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

CREATE VIEW ACTORS AS             -- This table will for store details of actors
SELECT *
FROM role_mapping as rm
INNER JOIN names as n
ON rm.name_id= n.id
WHERE category='actor';

CREATE VIEW movies_India AS             -- This table will store details of movies in India
SELECT *
FROM movie
WHERE country regexp 'India';

SELECT a.name as actor_name,
		sum(r.total_votes) as total_votes,             
        count(distinct a.movie_id) as movie_count,
        (sum(r.avg_rating* r.total_votes)/sum(r.total_votes)) as actor_avg_rating, -- finding weighted average rating for each actor using total votes as weight
        RANK() OVER(ORDER BY (sum(r.avg_rating* r.total_votes)/sum(r.total_votes)) DESC, r.total_votes DESC) as actor_rank    -- rank of actors by avg_rating. For actors with same average rating, we then rank them by total votes in descending order
FROM ACTORS as a
INNER JOIN movies_India as mi         -- joining the view ACTORS with the view movies_India
ON a.movie_id= mi.id
	INNER JOIN ratings as r             -- joining ratings
    ON a.movie_id= r.movie_id
group by actor_name                    -- grouping by actor
having movie_count>=5
limit 1;               -- we are only considering actors who have acted in atlease 5 movies
									-- Top actor is Vijay Sethupathi

DROP VIEW ACTORS;           -- Dropping both the view tables for actors and movies in india as our job is done
DROP VIEW movies_India;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

CREATE VIEW ACTRESSES AS             -- This table will for store details of ACTRESSES
SELECT *
FROM role_mapping as rm
INNER JOIN names as n
ON rm.name_id= n.id
WHERE category='actress';

CREATE VIEW hindi_movies_India AS             -- This table will store details of hindi movies in India
SELECT *
FROM movie
WHERE country regexp 'India' and languages regexp 'Hindi';  -- filtering movies by country India and languages Hindi

SELECT a.name as actress_name,
		sum(r.total_votes) as total_votes,             
        count(distinct a.movie_id) as movie_count,
        (sum(r.avg_rating* r.total_votes)/sum(r.total_votes)) as actress_avg_rating, -- finding weighted average rating for each actress using total votes as weight
        RANK() OVER(ORDER BY (sum(r.avg_rating* r.total_votes)/sum(r.total_votes)) DESC, r.total_votes DESC) as actress_rank    -- rank of actresses by avg_rating. For actresses with same average rating, we then rank them by total votes in descending order
FROM ACTRESSES as a
INNER JOIN hindi_movies_India as mi         -- joining the view ACTRESSES with the view hindi_movies_India
ON a.movie_id= mi.id
	INNER JOIN ratings as r             -- joining ratings
    ON a.movie_id= r.movie_id
group by actress_name                    -- grouping by actresses
having movie_count>=3
limit 3;                           -- top 3 actresses
			  -- Taapsee Pannu is the top actress





/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

with thriller_movies
as
(                                 -- This CTE will contain the details of Thriller movies
SELECT m.title,
		m.id,
        g.genre,
        r.avg_rating
FROM genre as g
INNER JOIN ratings as r        -- joining genre andh ratings tables
ON g.movie_id= r.movie_id       -- joining movie table as well to get the movie titles
	INNER JOIN movie as m
    ON g.movie_id=m.id
WHERE g.genre= 'Thriller'      -- filtering by thriller movies
)
SELECT *,
        CASE                                            -- classifying the movies into different categories based on their avg_rating
			WHEN avg_rating>8 then 'Superhit movies'
            WHEN avg_rating between 7 and 8 then 'Hit movies'
            WHEN avg_rating between 5 and 7 then 'One-time-watch movies'
            WHEN avg_rating<5 then 'Flop movies'
		END as Movie_Category
FROM thriller_movies;



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

with avg_duration_per_genre
as
(                               -- finding the avg_duration per genre
SELECT genre,
		avg(duration) as avg_duration
FROM movie as m
INNER JOIN genre as g
ON m.id= g.movie_id
group by genre
)
SELECT *, 
		sum(round(avg_duration,2)) over w1 as running_total_duration,  -- finding cumulative sum of avg_duration of genres. 
        avg(avg_duration) over w2 as moving_avg_duration     -- finding moving averages of avg_duration of genres. 
FROM avg_duration_per_genre
WINDOW w1 as (ORDER BY genre ROWS UNBOUNDED PRECEDING), -- window for cumulative sum
w2 as (ORDER BY genre ROWS UNBOUNDED PRECEDING);   -- window for moving average
        
        
        







-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies


-- We already know from our previous queries that Drama, Comedy or Thriller are the top 3 genres in terms of number of movies produced
-- So writing the query now

with movies_ranked_by_grossIncome  
as(
select genre,
        year,
        title as movie_name,
        worlwide_gross_income,
        dense_rank() over (partition by year order by worlwide_gross_income desc) as movie_rank  -- raniking for each year separately based on worlwide_gross_income 
        
from movie m inner join genre g on               -- joining movie and genre tables
m.id= g.movie_id
where genre= 'Drama' or genre= 'Comedy' or genre='Thriller'   -- We already know from our previous queries that Drama, Comedy or Thriller are the top 3 genres in terms of number of movies produced
)
SELECT * 
FROM movies_ranked_by_grossIncome          -- selecting the top 5 ranked movies for each year 
WHERE movie_rank<=5;             


with movies_ranked_by_grossIncome  
as(
select genre,
        year,
        title as movie_name,
        worlwide_gross_income,
        dense_rank() over (partition by year order by worlwide_gross_income desc) as movie_rank  -- raniking for each year separately based on worlwide_gross_income 
        
from movie m inner join genre g on               -- joining movie and genre tables
m.id= g.movie_id
where genre= 'Drama' or genre= 'Comedy' or genre='Thriller'   -- We already know from our previous queries that Drama, Comedy or Thriller are the top 3 genres in terms of number of movies produced
)
SELECT * 
FROM movies_ranked_by_grossIncome          -- selecting the top 5 ranked movies for each year 
WHERE movie_rank<=5;             
   
SELECT *
FROM movie
WHERE worlwide_gross_income is not null and worlwide_gross_income regexp 'INR';

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select 
    production_company, count(m.id) as movie_count,               
    rank() over (order by count(m.id) desc) as prod_comp_rank  -- ranking based on count of hit movies (median rating >= 8)
    from
         movie m 
    join 
        ratings r 
    on
        m.id = r.movie_id       -- joining movie and ratings table to get the median rating
    where
        median_rating >= 8 and production_company is not null and POSITION(',' IN languages)>0 -- a movie is a hit if median rating >= 8
    group by 
        production_company      -- grouping by production house
    limit 2                      -- we want the top 2 production companies only
;
                               -- Star Cinema and Twentieth Century Fox are the top 2 production houses that have produced the highest number of hits among multilingual movies





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

select 
    n.name as actress_name, sum(r.total_votes) as total_votes, count(rm.movie_id) as movie_count, 
    r.avg_rating as actress_avg_rating, rank() over (order by avg_rating desc) as actress_rank  -- ranking each actress by count of superhit movies
    from names n
    join role_mapping rm                    -- joining role_mapping and names tables
    on n.id = rm.name_id
    join ratings r                           -- joining ratings table
    on rm.movie_id = r.movie_id
    join genre g                                -- joining genre table
    on r.movie_id = g.movie_id
    where genre = 'drama' and category = 'actress' and avg_rating >8  -- filtering by actresses, drama genre and movies with avg_rating >8
    group by actress_name                                -- grouping by each actress
    limit 3
;                                       -- Sangeetha Bhat, Fatmire Sahiti and Adriana Matoshi are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

with director_details
as
(                                                              -- This CTE will fetch the director details
SELECT name_id as director_id,                                 
		name as director_name,
        dm.movie_id,
        m.title,
        m.date_published,
        r.avg_rating,
        r.total_votes,
        m.duration        
FROM director_mapping as dm
INNER JOIN names as n                     -- joining names table
ON dm.name_id= n.id
	INNER JOIN movie as m                      -- joining movies table
    ON dm.movie_id= m.id
		INNER JOIN ratings as r                 -- joining ratings table
        ON dm.movie_id= r.movie_id
),
next_date_published as 
(                                                       -- This CTE will find the next publishing date of each director's next movie
SELECT *, 
		lead(date_published, 1) OVER(PARTITION BY director_id ORDER BY date_published, movie_id) as next_date_published  -- This will find the next publishing date of each director's next movie
FROM director_details
),
diff_in_date_published_in_days                          -- This CTE will find the date difference between date published and next date published between movies of each director in days
as
(
SELECT *,
		datediff(next_date_published, date_published) as inter_movie_duration -- date difference between date published and next date published between movies of each director in days

FROM next_date_published

),
directors_ranked as                                  
(                                      -- This CTE will rank all the directors based on the number of movies produced. For those directors ending up in same rank, we break the tie using avg_rating
SELECT director_id,
		director_name,
        count(movie_id) as number_of_movies,
        avg(inter_movie_duration) as avg_inter_movie_days,
        avg(avg_rating) as avg_rating,
        sum(total_votes) as total_votes,
        min(avg_rating) as min_rating,
        max(avg_rating) as max_rating,
        sum(duration) as total_duration,
        ROW_NUMBER() OVER(ORDER BY count(movie_id) DESC, avg_rating DESC) AS rank_of_director  -- ranking all the directors based on the number of movies produced. For those directors ending up in same rank, we break the tie using avg_rating
 FROM diff_in_date_published_in_days
 group by director_id                                            -- grouping by each director
 )
 SELECT director_id,                                                      -- top 9 directors selected
		director_name,
        number_of_movies,
        avg_inter_movie_days,
        avg_rating,
        total_votes,
        min_rating,
        max_rating,
        total_duration                                       
FROM directors_ranked
WHERE rank_of_director<=9;                                          -- A.L. Vijay and Andrew Jones are topping the leaderboard.
 
        





