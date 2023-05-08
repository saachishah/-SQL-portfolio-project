
-- number of rows in our dataset
select count(*) from project..Data1$
select count(*) from project..Sheet1$

-- Calculate dataset for Jharkhand and Bihar
select * from project..Data1$ where [State ] in ( 'Jharkhand', 'Bihar')

-- Calculate the total population in India
select sum(population) as Population from project..Sheet1$

-- Calculate Average growth percentage for India
select avg(growth)*100 as Average_Growth from project..Data1$

-- Calculate Average growth percentage for entire state
select [State ], avg(growth)*100 as Average_Growth from project..Data1$ where [State ]  is not null group by [State ] 

-- Calculate Average sex ratio
select [State ] ,round(avg(Sex_Ratio),0) as avg_sex_ratio from project..Data1$ where [State ]  is not null group by [State ] 

-- Calculate Average literacy rate
select [State ] ,round(avg(Literacy),0) as avg_literacy_ratio from project..Data1$ where [State ]  is not null group by [State ] having round(avg(Literacy),0) >90 order by avg_literacy_ratio
desc 

-- Calculate Top 3 states with Highest growth percentage ratio
select top 3 [State ], avg(growth)*100 as Average_Growth from project..Data1$ where [State ]  is not null group by [State ] order by Average_Growth

-- Calculate Bottom 3 states with lowest sex ratio
select top 3 [State ] ,round(avg(Sex_Ratio),0) as avg_sex_ratio from project..Data1$ where [State ] is not null group by [State ] order by avg_sex_ratio asc

-- Calculate top 3 and bottom 3  states in literacy rate

drop table if exists topstates;
create table topstates
( state nvarchar(255),
  topstate float
  )
insert into topstates
select top 3 [State ] ,round(avg(Literacy),0) as avg_literacy from project..Data1$ where [State ] is not null group by [State ] order by avg_literacy desc
select top 3 * from topstates order by topstates.topstate desc;

drop table if exists bottomstates
create table bottomstates
( state nvarchar(255),
  bottomstate float
  )
insert into bottomstates
select top 3 [State ] ,round(avg(Literacy),0) as avg_literacy from project..Data1$ where [State ] is not null group by [State ] order by avg_literacy desc
select top 3 * from bottomstates order by bottomstates.bottomstate asc;

-- Using Union Operatorn for final result
select * from(
select top 3 * from topstates order by topstates.topstate desc) a

union
select * from (
select top 3 * from bottomstates order by bottomstates.bottomstate asc) b;

-- States starting with letter A

select distinct [State ] from project..Data1$ where lower([State ]) like 'a%'

-- States starting with letter A and ending with letter M

select distinct [State ] from project..Data1$ where lower([State ]) like 'a%' and lower([State ]) like '%m'

-- Calculate total number of males and females in states
select d.[State ], sum(d.males) total_males, sum(d.females) total_females from
(select c.District, c.[State ], round(c.Population/(c.Sex_Ratio+1),0) males, round((c.Population*c.Sex_Ratio)/(c.Sex_Ratio+1),0) females from
(select a.District, a.[State ], a.Sex_Ratio, b.Population from project..Data1$ a inner join project..Sheet1$ b on a.District = b.[District ]) c) d
group by d.[State ];

-- Calculate Total Literacy Rate


select c.[State ],sum(literate_people) total_literate_pop,sum(illiterate_people) total_lliterate_pop from 

(select d.district,d.[State ],round((d.literacy_ratio*d.Population),0) literate_people,
round((1-d.literacy_ratio)* d.Population,0) illiterate_people from

(select a.district,a.[State ],a.literacy/100 literacy_ratio,b.population from project..Data1$ a 
inner join project..Sheet1$ b on a.district=b.[District ]) d) c
group by c.[State ]

-- Calculate population in previous census


select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from

(select e.State, sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from

(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..Data1$ a inner join project..Sheet1$ b on a.district=b.[District ]) d) e
group by e.state) m



-- population vs area

select (g.total_area/g.previous_census_population)  as previous_census_population_vs_area, (g.total_area/g.current_census_population) as 
current_census_population_vs_area from
(select q.*,r.total_area from 
(select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population,sum(m.current_census_population) current_census_population from (
select e.state,sum(e.previous_census_population) previous_census_population,sum(e.current_census_population) current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) previous_census_population,d.population current_census_population from
(select a.district,a.state,a.growth growth,b.population from project..Data1$ a inner join project..Sheet1$ b on a.district=b.[District ]) d) e
group by e.state)m) n) q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from project..Sheet1$)z) r on q.keyy=r.keyy)g

select * from project..Data1$

-- Using window function


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from project..Data1$) a

where a.rnk in (1,2,3) order by state