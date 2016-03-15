--Top address for enrolled students
SELECT
	p.personid,
	a.addressid,
	a.number,
	a.city,
	a.state,
	a.zip
FROM
	dbo.person p
	INNER JOIN dbo.enrollment as enr on p.personid = enr.personid
	INNER JOIN dbo.schoolyear as  sy on sy.endyear = enr.endyear and sy.active = 1
	--Inline view that selects the top address for every person
	INNER JOIN (select
		   p1.personid,
		   (
		   select top(1) AddressOrder.addressid
		   from 
				  (
				  select top(1) 
						 p.personid,
						 isnull(hm.secondary,0) as hm_secondary,
						 isnull(rp.seq,255) as rp_seq, 
						 isnull(rp.guardian,0)  as rp_guardian,
						 rp.mailing as rp_mailing,
						 a.number as address_number,
						 rp.name as rp_name,
						 a.addressid
				  from 
						 dbo.Person p WITH (NOLOCK)                                                 
							   left outer join relatedpair rp WITH (NOLOCK) on rp.personid1 = p.personid
													AND (rp.enddate is null or rp.endDate >= cast(GETDATE() as date) ) 
							   LEFT OUTER JOIN dbo.HouseholdMember hm WITH (NOLOCK) ON (hm.startDate IS NULL OR cast(hm.startDate as date) <= cast(GETDATE() as date) )
															 and (hm.endDate IS NULL OR cast(hm.endDate as date) >= cast(GETDATE() as date) )
																AND hm.personID = p.personID 
							   LEFT OUTER JOIN dbo.Household h WITH (NOLOCK) ON h.householdID = hm.householdID 
							   LEFT OUTER JOIN dbo.HouseholdLocation hl WITH (NOLOCK) ON hl.householdID = h.householdID 
																			AND (hl.enddate is null OR cast(hl.endDate as date) >= cast(GETDATE() as date) )
							   LEFT OUTER JOIN dbo.address a with (nolock) on hl.addressid = a.addressid                       
				  where 
						 (p.personID= p1.personID)            
				  order by
						 1,  -- personid
						 2,   -- secondary asc sort so 0's come first
						 --5, -- mailing desc sort so 1 comes before 0 
						 3,   -- seq asc sort - this is a freeform entry field as tinyint with max value = 255 - person notified first should get a 1 and if null then put last ...
						 4 desc,   -- related pair guardian desc sort so 1 comes before 0 
						 5 desc, -- mailing desc sort so 1 comes before 0 
						 6 desc  -- number column from address table desc sort so nulls come last
				  )      AddressOrder
		   ) as TopAdId
			from 
				dbo.person p1 ) as topad on topad.personid = p.personid
	INNER JOIN dbo.address a on a.addressid = topad.TopadID
WHERE
	enr.enddate is null 
	and enr.endyear = 2015 
	and isnull(enr.noshow,0) = 0