use PortofolioProject
go

--first of all in order to understand the context of the tables let's select all columns 
select*
from dbo.OlympicGames_t1;

select*
from dbo.OlympicGames_t2;

--from the second statement above we see that columns don't have a name
--let's give them names

exec sp_rename 'dbo.OlympicGames_t2.Column1','NOC','COLUMN';
exec sp_rename 'dbo.OlympicGames_t2.Column2','Region','COLUMN';
exec sp_rename 'dbo.OlympicGames_t2.Column3','Notes','COLUMN';

--number of Greek athletes participated in 2004 Olympics
select
COUNT(distinct ID)
from dbo.OlympicGames_t1 as t1
inner join
dbo.OlympicGames_t2 as t2 on t1.NOC=t2.NOC
WHERE t2.Region='Greece'
and Year=2004;

--how many Greek athletes winned a medal in 2004 Olympics
select
Medal,
COUNT(distinct ID) as no_of_athletes
from dbo.OlympicGames_t1 as t1
inner join
dbo.OlympicGames_t2 as t2 on t1.NOC=t2.NOC
WHERE t2.Region='Greece'
and Year=2004
group by Medal;

--from the following queries we can see that in 1904 Olympics only 6 women participated while in 1924 this number raised up to 169
select distinct ID,Name 
from dbo.OlympicGames_t1 
where Year=1904
and Sex='F';

select distinct ID,Name 
from dbo.OlympicGames_t1 
where Year=1924
and Sex='F';

--list of Greek athletes with all the events participated in 2012 London Olympics
select
distinct ID,
Name,
Sex,
Age,
Event
from dbo.OlympicGames_t1 as t1
inner join
dbo.OlympicGames_t2 as t2 on t1.NOC=t2.NOC
WHERE t2.Region='Greece'
and Year=2012;

go

--creating a procedure in order to get the list of athletes participated in 2012 Olympics from every Region we want
create procedure dbo.getAthletesByRegion(@Region nvarchar(255))
as
select
distinct ID,
Name,
Sex,
Age,
Event
from dbo.OlympicGames_t1 as t1
inner join
dbo.OlympicGames_t2 as t2 on t1.NOC=t2.NOC
WHERE t2.Region= @Region
and Year=2012;

go

--executing the procedure to obtain results about Italy and France
execute dbo.getAthletesByRegion @Region='Italy';
execute dbo.getAthletesByRegion @Region='France';

go

--creating a second procedure with two input parameters
create procedure dbo.AthletesByRegionAndYear(@Region nvarchar(255),@Year float)
as
select
distinct ID,
Name,
Sex,
Age,
Event
from dbo.OlympicGames_t1 as t1
inner join
dbo.OlympicGames_t2 as t2 on t1.NOC=t2.NOC
WHERE t2.Region= @Region
and Year=@Year;

go

--executing the procedure
execute dbo.AthletesByRegionAndYear @Region='Greece', @Year=1996;
execute dbo.AthletesByRegionAndYear @Region='Germany', @Year=1992;

go

--creating a view to get only specific personal information about athletes who took part in 2008 Olympics
create view v_athletes_info as
select
distinct ID,
Name,
Sex,
Age,
Height,
Weight,
Event
from dbo.OlympicGames_t1
where Year=2008;

go

--quering the view
select*
from v_athletes_info;

--looking at the average age of athletes per country for 2012 Olympics
--ordering the query by descening order
select
t2.Region,
AVG(cast(age as tinyint)) as average_age
from dbo.OlympicGames_t1 as t1
inner join
dbo.OlympicGames_t2 as t2 on t1.NOC=t2.NOC
where Year=2012
group by t2.Region
order by average_age desc;

--getting the average age of athletes for 1996 Olympics
select AVG(cast(age as tinyint))
from dbo.OlympicGames_t1 
where Year=1996;

--because we got an error message in the previous query we will exclude athletes with NA Age
select AVG(cast(age as tinyint))
from dbo.OlympicGames_t1 
where Year=1996
and Age!='NA';

--using a cte to see how many athletes in 1996 Olympics were above the average age
with cte as
(select AVG(convert(tinyint,age)) as avg_age
from dbo.OlympicGames_t1 
where Year=1996
and Age!='NA')
select
SUM(case
    when t1.Age>c.avg_age then 1
	else 0
	end) as no_of_athletes_above_average,
COUNT(distinct ID) as total_no_of_athletes
from dbo.OlympicGames_t1 as t1
cross join
cte as c
where Year=1996
and Age!='NA';