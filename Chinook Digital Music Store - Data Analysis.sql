use chinook;
select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

select count(*) from InvoiceLine;
-- Using SQL solve the following problems using the chinook database.
-- 1) Find the artist who has contributed with the maximum no of albums. Display the artist name and the no of albums.

select count(title) from album;

-- select a1.title from album as a1 join album as a2 on a1.AlbumId>a2.AlbumId and a1.title=a2.title; -- 'Minha História'
-- select title, AlbumId, ArtistId from album where Title='Minha História';

use chinook;

select ar.name, count(AlbumId) as tot_no_of_alb
from Artist as ar
join Album as al on al.ArtistId=ar.ArtistId
group by ar.name
order by tot_no_of_alb desc
limit 1;

with temp as
    (select alb.artistid
    , count(1) as no_of_albums
    , rank() over(order by count(1) desc) as rnk
    from Album alb
    group by alb.artistid)
select art.name as artist_name, t.no_of_albums
from temp t
join artist art on art.artistid = t.artistid
where rnk = 1;


-- 2) Display the name, email id, country of all listeners who love Jazz, Rock and Pop music.


select concat(c.FirstName, " ", c.LastName) as customer_name
, c.email, c.country, g.name as genre
from InvoiceLine il
join track t on t.trackid = il.trackid
join genre g on g.genreid = t.genreid
join Invoice i on i.invoiceid = il.invoiceid
join customer c on c.customerid = i.customerid
where g.name in ('Jazz', 'Rock', 'Pop');


-- 3) Find the employee who has supported the most no of customers. Display the employee name and designation
 
 -- Most no of customer
with cte as (
			select concat(e.FirstName, " ", e.LastName) as emp_name, e.Title as designation, count(SupportRepId) as no_of_customers
            from Employee as e
            join Customer as c on e.EmployeeId=c.SupportRepId
			group by emp_name, designation
		    order by no_of_customers desc
            limit 1)
select emp_name, designation from cte;


select employee_name, title as designation
from (
    select concat(e.FirstName, " ", e.LastName) as employee_name, e.title
    , count(1) as no_of_customers
    , rank() over(order by count(1) desc) as rnk
    from Customer c
    join employee e on e.employeeid=c.supportrepid
    group by e.firstname,e.lastname, e.title) x
where x.rnk=1; -- Thoufiq


select distinct concat(emp.firstname,' ',emp.lastname) as Employee_Name, emp.title as Designation, count(cus.customerid) as No_of_Customers_Supported
from Employee emp
left join Customer cus on emp.employeeid = cus.supportrepid
group by Employee_Name, Designation
order by No_of_Customers_Supported desc; -- limit 1;

/* select count(SupportRepId)
from customer
where SupportRepId=3*/

-- 4) Which city corresponds to the best customers?

select billingcity, sum(total) as Total_Revenue
from invoice
group by billingcity
order by Total_Revenue desc
limit 1; -- Top 5 best cities are displayed;

with temp as
    (select city, sum(total) total_purchase_amt
    , rank() over(order by sum(total) desc) as rnk
    from Invoice i
    join Customer c on c.Customerid = i.Customerid
    group by city)
select city
from temp
where rnk=1; -- Toufiq

-- 5) The highest number of invoices belongs to which country?

select i.BillingCountry, count(i.InvoiceId)
from Invoice as i
group by i.BillingCountry
order by count(i.InvoiceId) desc
limit 1;

select billingcountry, count(invoiceid) as Total_No_Invoices
from invoice
group by billingcountry
order by Total_No_Invoices desc limit 1; /*Ans: USA - 91 Invoices */



select country
from (
    select billingcountry as country, count(1) as no_of_invoice
    , rank() over(order by count(1) desc) as rnk
    from Invoice
    group by billingcountry) x
where x.rnk=1;

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

-- 6) Name the best customer (customer who spent the most money).

with cte as (
      select concat(c.FirstName, " ", c.LastName) as cust_name, c.CustomerId, sum(i.Total) as tot
	  from Customer as c
      join invoice as i on c.CustomerId=i.CustomerId
      group by cust_name, c.CustomerId
      order by tot desc)	
select cust_name 
from cte
where tot = (select max(tot) from cte);

select concat(c.FirstName, " ", c.LastName) as customer_name
from (
    select customerid, sum(total) total_purchase
    , rank() over(order by sum(total) desc) as rnk
    from Invoice
    group by customerid) x
join customer c on c.customerid = x.customerid
where rnk=1;


-- 7) Suppose you want to host a rock concert in a city and want to know which location should host it.
-- Query the dataset to find the city with the most rock-music listeners to answer this question.

select c.city,c.country,g.name,sum(i.total) as total
from customer c
left join invoice i on i.customerid = c.customerid
left join invoiceline iv on iv.invoiceid = i.invoiceid
left join track t on iv.trackid = t.trackid
join genre g on g.genreid = t.genreid
group by c.city,c.country,g.name
having g.name = 'Rock'
order by total desc
limit 1; -- Need to check

select I.billingcity, count(1)
from Track T
join Genre G on G.genreid = T.genreid
join InvoiceLine IL on IL.trackid = T.trackid
join Invoice I on I.invoiceid = IL.invoiceid
where G.name = 'Rock'
group by I.billingcity
order by 2 desc;

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

/* 8) Identify all the albums who have less then 5 track under them.
    Display the album name, artist name and the no of tracks in the respective album.*/
    
select count(*) from Track;
select count(distinct Name) from Track;

with cte as (
        select a.title as alb_name, ar.ArtistId, ar.name as artist_name, count(t.TrackId) as tot_trk_cnt
        from Album as a
        left join Track as t on a.AlbumId=t.AlbumId
        left join Artist as ar on ar.ArtistId=a.ArtistId
        group by alb_name, ar.ArtistId
        having tot_trk_cnt<5
        order by count(TrackId) desc)
select alb_name, artist_name, tot_trk_cnt
from cte; -- Shubham

with temp as
    (select t.albumid, count(1) as no_of_tracks
    from Track t
    group by t.albumid
    having count(1) < 5
    order by 2 desc)
select al.title as album_title, art.name as artist_name, t.no_of_tracks
from temp t
join album al on t.albumid = al.albumid
join artist art on art.artistid = al.artistid
order by t.no_of_tracks desc;

with album_track_artist_list as
(
select alb.title as Album_Title, artst.name as Artist_Name, count(trk.trackid) as No_of_Tracks
from Album alb
left join Track trk on alb.albumid = trk.albumid
left join artist artst on alb.artistid = artst.artistid
group by Album_Title, Artist_Name
order by No_of_Tracks desc
)
select *
from album_track_artist_list as list
where No_of_Tracks <5; -- Raghvendra

-- 9) Display the track, album, artist and the genre for all tracks which are not purchased.


select t.name as track_name, al.title as album_title, art.name as artist_name, g.name as genre
from Track t
join album al on al.albumid=t.albumid
join artist art on art.artistid = al.artistid
join genre g on g.genreid = t.genreid
where not exists (select 1
                 from InvoiceLine il
                 where il.trackid = t.trackid);
				

-- 10) Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

with Artist_List as
(
select distinct artst.name as Artist_Name, gnr.name as Genre_Name
from Artist artst
left join Album albm on artst.artistid = albm.albumid
left join Track trk on trk.albumid = albm.albumid
left join Genre gnr on trk.genreid = gnr.genreid
order by Artist_Name),
genre_count as
(select artist_Name, count(genre_name) as genre_count
from Artist_List group by artist_Name
)
select artlst.artist_name, artlst.genre_name
from Artist_List artlst
join genre_count gcnt on artlst.Artist_Name = gcnt.artist_Name
where gcnt.genre_count>1; -- Raghavendra

with temp as
        (select distinct art.name as artist_name, g.name as genre
        from Track t
        join album al on al.albumid=t.albumid
        join artist art on art.artistid = al.artistid
        join genre g on g.genreid = t.genreid
        order by 1,2),
    final_artist as
        (select artist_name
        from temp t
        group by artist_name
        having count(1) > 1)
select t.*
from temp t
join final_artist fa on fa.artist_name = t.artist_name
order by 1,2;


-- Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

with cte as
(
select ar.name artist_name,g.name as genre_name,rank() over(order by ar.name) as rn
from artist ar
left join album al on ar.artistid = al.artistid
left join track t on t.albumid =al.albumid
left join genre g on g.genreid = t.genreid
group by ar.name,g.name
having count(ar.name) > 1
order by artist_name
)
select artist_name,genre_name
from cte c1
where c1.rn in (select rn from cte
where rn = c1.rn
and c1.genre_name <> cte.genre_name);


-- Find artist who have performed in multiple genres. Diplay the aritst name and the genre.

select a.Name as artist_name, g.Name as genre_name
from Artist as a
left join album as al on a.ArtistId=al.ArtistId
left join Track as t on al.AlbumId=t.AlbumId
join Genre as g on t.GenreId=g.GenreId
group by artist_name, genre_name
having count(artist_name)>1
order by artist_name;


select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from MediaType; -- 5
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

-- 11) Which is the most popular and least popular genre?

with temp as
        (select distinct g.name
        , count(1) as no_of_purchases
        , rank() over(order by count(1) desc) as rnk
        from InvoiceLine il
        join track t on t.trackid = il.trackid
        join genre g on g.genreid = t.genreid
        group by g.name
        order by 2 desc),
    temp2 as
        (select max(rnk) as max_rnk from temp)
select name as genre
, case when rnk = 1 then 'Most Popular' else 'Least Popular' end as popular
from temp
cross join temp2
where rnk = 1 or rnk = max_rnk;

-- 12) Identify if there are tracks more expensive than others. If there are then display the track name along with the album title and artist name for these expensive tracks.

select t.name as track_name, al.title as album_name, art.name as artist_name
from Track t
join album al on al.albumid = t.albumid
join artist art on art.artistid = al.artistid
where unitprice > (select min(unitprice) from Track);

-- Are there any albums owned by multiple artist?

with cte as(
  select a1.Title, a1.ArtistId
  from Album as a1
  join Album as a2 on a1.Title=a2.Title and a1.ArtistId<>a2.ArtistId)
select cte.Title, a.Name
from cte
join Artist as a on cte.ArtistId=a.ArtistId; 



use chinook;

-- 14) Find the artist who has contributed with the maximum no of songs/tracks. Display the artist name and the no of songs.

select name, cnt from (
    select ar.name,count(1) as cnt
    ,rank() over(order by count(1) desc) as rnk
    from Track t
    join album a on a.albumid = t.albumid
    join artist ar on ar.artistid = a.artistid
    group by ar.name
    order by 2 desc) x
where rnk = 1; -- Toufiq

-- 16) Is there any invoice which is issued to a non existing customer?

select InvoiceId
from Invoice
where CustomerId not in (select distinct CustomerId from Customer);

select * from Invoice I
where not exists (select 1 from customer c 
                where c.customerid = I.customerid);

-- 17) Is there any invoice line for a non existing invoice?

select InvoiceLineId
from InvoiceLine
where InvoiceId not in (select InvoiceId from Invoice);


select * from Album; -- 347
select * from Artist; -- 275
select * from Customer; -- 59
select * from Employee; -- 8
select * from Genre; -- 25
select * from Invoice; -- 412
select * from InvoiceLine; -- 2240
select * from Playlist; -- 18
select * from PlaylistTrack; -- 8715
select * from Track; -- 3503

-- 18) Are there albums without a title?

Select *
from Album
where Title is null;

-- 19) Are there invalid tracks in the playlist?

select PlaylistId
from PlaylistTrack
where TrackId not in (SELECT DISTINCT trackid FROM Track);