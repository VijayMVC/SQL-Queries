use milwaukee;
go
select *
from 
	dbo.customstudent
where 
	value like 'Mor%'
	and
	attributeid in (647 --1award
					,646 --1amount
					,648 --1date
					,650 --2award
					,649 --2amount
					,651 --2date
					,1791 --3award
					,1790 --3amount
					,1972 --3date
					,1796 --4award
					,1797 --4amount
					,1798 --4date
					,1951 --5award
					,1959 --5amount
					,1955 --5date
					,1952 --6amount
					,1960 --6award														 
					,1956 --6date
					,1953 --7award
					,1961 --7amount
					,1957 --7date
					,1954 --8award
					,1962 --8amount
					,1958) --8date 
