SELECT
	per.personID,
	per.studentNumber,
	enr.enrollmentID,
	id.firstname,
	id.lastname,
	(id.lastname + ', ' + id.firstname) as full_name,
	id.gender,
	id.birthdate,
	--id.raceethnicityfed,
	enr.grade,
	--a.city as student_city,
	sch.name,
	cal.name as calendar,
	enr.startDate,
	enr.endDate,
	enr.endStatus,
	enr.withdrawDate,
	case when enr.grade in ('06', '07', '08') then saa.saa_mid
		when enr.grade in ('09', '10', '11', '12', '12+') then saa.saa_high
		else saa.saa_elem end as new_school_override,
	attd_sch.name as attd_area_school
FROM
    dbo.Enrollment enr WITH (NOLOCK)
	INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
	INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
    INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = enr.endyear
    INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
	INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
	INNER JOIN 
		(select
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
				dbo.person p1 ) as topad on topad.personid = per.personid
	INNER JOIN dbo.address a on a.addressid = topad.TopadID
	LEFT OUTER JOIN dbo.mai_address saa on saa.mai_rcd_nbr = a.MAI_RCD_NBR
	LEFT OUTER JOIN dbo.school attd_sch on case when enr.grade in ('06', '07', '08') then saa.saa_mid
										when enr.grade in ('09', '10', '11', '12', '12+') then saa.saa_high
										else saa.saa_elem end = attd_sch.number
WHERE
	 sy.active = 1
	 and cal.exclude <> 1
	 and enr.stateExclude <> 1
	 and (enr.enddate is null or datename(mm, enr.enddate) <> 'July')
	 and cal.calendarid in (3230, 3336, 3344, 3345, 3370, 3371, 3315, 3291)
ORDER BY 
	sch.name, enr.startdate