select * from seasons order by year ; -- 74
select * from status; -- 139	
select * from circuits; -- 77
select * from races; -- 1102
select * from drivers; -- 857
select * from constructors; -- 211
select * from constructor_results; -- 12170
select * from constructor_standings; -- 12941
select * from driver_standings; -- 33902
select * from lap_times; -- 538121
select * from pit_stops; -- 9634
select * from qualifying; -- 9575
select * from results; -- 25840
select * from sprint_results; -- 120


-- Using the given F1 dataset, solve the following problems:
1. Identify the country which has produced the most F1 drivers.
2. Which country has produced the most no of F1 circuits
3. Which countries have produced exactly 5 constructors?
4. List down the no of races that have taken place each year
5. Who is the youngest and oldest F1 driver?
6. List down the no of races that have taken place each year and mentioned which
was the first and the last race of each season.
ER Diagram
Formula 1 - Case Study using SQL 3
7. Which circuit has hosted the most no of races. Display the circuit name, no of races,
city and country.
8. Display the following for 2022 season:
Year, Race_no, circuit name, driver name, driver race position, driver race points,
flag to indicate if winner
, constructor name, constructor position, constructor points, , flag to indicate if
constructor is winner
, race status of each driver, flag to indicate fastest lap for which driver, total no of pit
stops by each driver
9. List down the names of all F1 champions and the no of times they have won it.
10. Who has won the most constructor championships
11. How many races has India hosted?
12. Identify the driver who won the championship or was a runner-up. Also display the
team they belonged to.
13. Display the top 10 drivers with most wins.
14. Display the top 3 constructors of all time.
15. Identify the drivers who have won races with multiple teams.
16. How many drivers have never won any race.
17. Are there any constructors who never scored a point? if so mention their name and
how many races they participated in?
18. Mention the drivers who have won more than 50 races.
19. Identify the podium finishers of each race in 2022 season
20. For 2022 season, mention the points structure for each position. i.e. how many
points are awarded to each race finished position.
21. How many drivers participated in 2022 season?
22. How many races has the top 5 constructors won in the last 10 years.
23. Display the winners of every sprint so far in F1
24. Find the driver who has the most no of Did Not Qualify during the race

1. Identify the country which has produced the most F1 drivers.

select count(*) from drivers;

select nationality, count(nationality) as tot
from drivers
group by nationality
order by count(nationality) desc
limit 1;

with cte as
(
  select nationality, count(nationality) over(partition by nationality) as tot
  from drivers)
select distinct nationality, tot
from cte
where tot=(select max(tot) from cte); -- Shubham


2. Which country has produced the most no of F1 circuits.

select count(country) from circuits

select count(distinct country) from circuits;

with cte as (
       select country, count(country) as tot, rank() over(order by count(country) desc) as rnk
       from circuits
       group by country)
select country, tot
from cte
where rnk=1; -- Shubham

select country,count(1) from circuits group by country order by 2 desc limit 1;

3. Which countries have produced exactly 5 constructors?

select nationality, count(*)
from constructors
group by nationality
having count(*)=5; -- Shubham

4. List down the no of races that have taken place each year

select year, count(raceid)
from races
group by year
order by year desc;


5. Who is the youngest and oldest F1 driver?

Select forename||' '||surname as  driver_name, DOB
from drivers
where dob = (select min(dob) from drivers)
union
Select forename||' '||surname as  driver_name, DOB
from drivers
where dob = (select max(dob) from drivers); -- Shubham

select max(case when rn=1 then forename||' '||surname end) as oldest_driver
	, max(case when rn=cnt then forename||' '||surname end) as youngest_driver
	from (
		select *, row_number() over (order by dob ) as rn, count(*) over() as cnt
		from drivers) x
	where rn = 1 or rn = cnt;


6. List down the no of races that have taken place each year and mentioned which
was the first and the last race of each season.

select distinct year
, count(1) over(partition by year) as no_of_races
, first_value(name) over(partition by year order by date) as first_race
, last_value(name) over(partition by year order by date
					   range between unbounded preceding and unbounded following) as last_race
from races
order by year desc;

7. Which circuit has hosted the most no of races. Display the circuit name, no of races,
city and country.

select * from circuits; -- 77
select * from races; -- 1102

with cte as (
       select c.name as circuit_name, c.location as city, c.country, count(*) as no_of_races, dense_rank() over(order by count(*) desc) as rnk
       from circuits as c
       join races as r on c.circuitid=r.circuitid
       group by circuit_name, city, c.country
       order by count(*) desc)
select circuit_name, city, country, no_of_races
from cte
where rnk=1; -- Shubham


9. List down the names of all F1 champions and the no of times they have won it.


with cte as 
				(select r.year, concat(d.forename,' ',d.surname) as driver_name
				, sum(res.points) as tot_points
				, rank() over(partition by r.year order by sum(res.points) desc) as rnk
				from races r
				join driver_standings ds on ds.raceid=r.raceid
				join drivers d on d.driverid=ds.driverid
				join results res on res.raceid=r.raceid and res.driverid=ds.driverid --and res.constructorid=cs.constructorid 
				--where r.year>=2000
				group by r.year,  res.driverid, concat(d.forename,' ',d.surname) ),
	cte_rnk as
				(select * from cte where rnk=1)
		select driver_name, count(1) as no_of_championships
		from cte_rnk
		group by driver_name
		order by 2 desc;
		
		
10. Who has won the most constructor championships

with cte as
				(select r.year, c.name as constructor_name
				, sum(res.points) as tot_points
				, rank() over(partition by r.year order by sum(res.points) desc) as rnk
				from races r
				join constructor_standings cs on cs.raceid=r.raceid
				join constructors c on c.constructorid = cs.constructorid
				join constructor_results res on res.raceid=r.raceid and res.constructorid=cs.constructorid --and res.constructorid=cs.constructorid 
				--where r.year>=2022
				group by r.year,  res.constructorid, c.name),
			cte_rnk as
				(select * from cte where rnk=1)
		select constructor_name, count(1) as no_of_championships
		from cte_rnk
		group by constructor_name
		order by 2 desc;

11. How many races has India hosted?

select c.name as circuit_name,c.country, count(1) no_of_races
	from races r
	join circuits c on c.circuitid=r.circuitid
	where c.country='India'
	group by c.name,c.country; 


12. Identify the driver who won the championship or was a runner-up. Also display the
team they belonged to.

with cte as 
			(select r.year, concat(d.forename,' ',d.surname) as driver_name, c.name as constructor_name
			, sum(res.points) as tot_points
			, rank() over(partition by r.year order by sum(res.points) desc) as rnk
			from races r
			join driver_standings ds on ds.raceid=r.raceid
			join drivers d on d.driverid=ds.driverid
			join results res on res.raceid=r.raceid and res.driverid=ds.driverid 
		    join constructors c on c.constructorid=res.constructorid 
			-- where r.year>=2020
			group by r.year,  res.driverid, concat(d.forename,' ',d.surname), c.name)
	select year, driver_name, case when rnk=1 then 'Winner' else 'Runner-up' end as flag 
	from cte 
	where rnk<=2;

13. Display the top 10 drivers with most wins.

select x.driver_name, x.cnt from 
	(select forename||' '||surname as driver_name, count(1) as cnt, dense_rank() over(order by count(1) desc) as rnk
	from driver_standings as ds
	join drivers as d on d.driverid=ds.driverid
	where position = 1
	group by driver_name
	order by count(1) desc) x
where rnk<11; --  Shubham


14. Display the top 3 constructors of all time.

select constructor_name, tot_wins from 
			(select c.name as constructor_name, count(1) as tot_wins, dense_rank() over(order by count(1) desc) as rnk
						from constructor_standings as cs
						join constructors as c on c.Constructorid=cs.Constructorid
						where position = 1
						group by c.name
						order by tot_wins desc) x
where x.rnk<=3; --  Shubham


15. Identify the drivers who have won races with multiple teams.

Select driverid, count(distinct constructorid) as constructor_count
from results
where Position = 1
group by driverid
having count(distinct constructorid)>1
order by driverid;

select driverid, driver_name, string_agg(constructor_name,', ')
	from (
		select distinct r.driverid
		, concat(d.forename,' ',d.surname) as driver_name
		, c.name as constructor_name
		from results r
		join drivers d on d.driverid=r.driverid
		join constructors c on c.constructorid=r.constructorid
		where r.position=1) x
	group by driverid, driver_name
	having count(1) > 1
	order by driverid, driver_name; 


16. How many drivers have never won any race.

select d.driverid
	, concat(d.forename,' ',d.surname) as driver_name
	, nationality
	from drivers d 
	where driverid not in (select distinct driverid
						  from driver_standings ds 
						  where position=1)
	order by driver_name;
	
17. Are there any constructors who never scored a point? if so mention their name and
how many races they participated in?

select cs.constructorid, c.name as constructor_name
	, sum(cs.points) as total_points
	, count(1) as no_of_races
	from constructor_results cs
	join constructors c on c.constructorid=cs.constructorid
	group by cs.constructorid, c.name
	having sum(cs.points) = 0
	order by no_of_races desc, constructor_name ;

18. Mention the drivers who have won more than 50 races.

select forename||' '||surname as driver_name, count(1) as no_of_wins
from driver_standings as ds
join drivers as d on d.driverid=ds.driverid
where position = 1
group by driver_name
having count(1) > 50
order by no_of_wins desc;

19. Identify the podium finishers of each race in 2022 season


select r.name as race
	, concat(d.forename,' ',d.surname) as driver_name
	, ds.position
	from driver_standings ds 
	join races r on r.raceid=ds.raceid
	join drivers d on d.driverid=ds.driverid
	where r.year = 2022
	and ds.position <= 3
	order by r.raceid; 
	
20) For 2022 season, mention the points structure for each position. i.e. how many points are awarded to each race finished position. 


with cte as 
	(select max(res.raceid) as raceid
	from races r
	join results res on res.raceid=r.raceid
	where year=2022)
select r.position, r.points
from results r
join cte on cte.raceid=r.raceid
where r.points > 0;	
	
21. How many drivers participated in 2022 season?

select count(distinct driverid) as no_of_drivers_in_2022
	from driver_standings
	where raceid in (select raceid from races r where year=2022); 


22. How many races has the top 5 constructors won in the last 10 years.
*** Correction to Question: How many races has each of the top 5 constructors won in the last 10 years.

with top_5_teams as
		(select constructorid, constructor_name
			from (
				select cs.constructorid, c.name as constructor_name
				, count(1) as race_wins
				, rank() over(order by count(1) desc) as rnk
				from constructor_standings cs
				join constructors c on c.constructorid=cs.constructorid
				where position = 1
				group by cs.constructorid, c.name
				order by race_wins desc) x
			where rnk <= 5)
	select cte.constructorid, cte.constructor_name, coalesce(cs.wins,0) as wins
	from top_5_teams cte 
	left join ( select cs.constructorid, count(1) as wins
				from constructor_standings cs 
				join races r on r.raceid=cs.raceid
				where cs.position = 1
				and r.year >= (extract(year from current_date) - 10)
			    group by cs.constructorid
			  ) cs 
		on cte.constructorid = cs.constructorid
	order by wins desc; -- Toufiq

23. Display the winners of every sprint so far in F1

select r.year, r.name, concat(d.forename,' ',d.surname) as driver_name
	from sprint_results sr
	join drivers d on d.driverid=sr.driverid
	join races r on r.raceid=sr.raceid
	where sr.position=1
	order by 1,2;
	
24. Find the driver who has the most no of Did Not Qualify during the race

with cte as (
			select concat(d.forename,' ',d.surname) as driver_name, count(1) as no_of_disqualified, 
	        dense_rank() over(order by count(1) desc) as rnk
			from drivers as d
			join results as r on d.driverid=r.driverid
			join status as s on r.statusid=s.statusid
			where s.status = 'Did not qualify'
			group by driver_name)
select driver_name, no_of_disqualified
from cte
where rnk=1; -- Shubham


