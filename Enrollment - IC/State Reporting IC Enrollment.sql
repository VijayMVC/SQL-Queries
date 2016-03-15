SELECT
	per.personID,
	per.studentNumber,
	enr.enrollmentID,
	id.firstname,
	id.lastname,
	(id.lastname + ', ' + id.firstname) as full_name,
	id.gender,
	id.birthdate,
	id.raceethnicityfed,
	enr.grade,
	a.city as student_city,
	sch.name,
	cal.name as calendar,
	enr.startDate,
	enr.endDate,
	enr.endStatus,
	enr.withdrawDate,
	--enr.endcomments,
	--enr.stateExclude,
	--census.value as current_census_status_code,
	census.name as current_census_status,
	case when census.value is null then 
			(case when oenr.name is not null then 'Open Enrollment'
				when chapter.name is not null then 'Integration Transfer Program C220'
				when sch.number = '9989' then 'Residential Treatment'
				when sch.number = '1067' then 's.118.15'
				when cal.calendarid = '3324' then 'Private School'
				when waiver.programid = '22' then 'Tuition - Paid'
				when waiver.programid = '23' then 'Tuition Waiver - Additional Year'
				when waiver.programid = '24' then 'Tuition Waiver - Current Year' else null end)
				else census.name end as new_census_status,
	party.name as current_third_party_provider,
	case when sch.number = '1269' then 'Wisconsin School for the Deaf'
		when sch.number = '1268' then 'Wisconsin School for the Blind'
		else null end as new_third_party_provider,
	--nonres.value as current_nonres_code,
	nonres.name as current_nonres_reason,
	payer.name as current_payer,
	case when UPPER(a.city) <> 'Milwaukee' then 
			(case when (census.value = 'O' or oenr.name is not null) then 'Open Enrollment'
				when (census.value = 'TR' or chapter.name is not null) then 'Chapter 220'
				when sch.number = '9989' then 'Residential Treatment' 
				when waiver.programid is not null then 'Tuition Waiver' else null end)
				else null end as new_nonres_reason,
	--enr.residentDistrict,
	res_dis.name as current_resident_distrist,
	(case when UPPER(a.city) <> 'MILWAUKEE' then a.city else null end) as new_resident_district,
	enr.servingDistrict as current_serving_district,
	(case when sch.number = '9988' then mpssite.school else null end) as new_serving_district_or_school,
	mpssite.school as mpssite_school,
	mpssite.district_number,
	mpssite.district_name,
	serv_dis.name as serv_dis_name,
	trans_dis.value as current_transfer_district,
	trans_sch.value as current_transfer_school,
	sch_override.name as current_school_override,
	case when sch.number in ('1067', '9990', '9989')
		then (case when enr.grade in ('06', '07', '08') then saa.saa_mid
					when enr.grade in ('09', '10', '11', '12', '12+') then saa.saa_high
					else saa.saa_elem end) else null end as new_school_override,
	chapter.name as chapter220_prog,
	chapter.startdate as chapter220_start,
	chapter.enddate as chapter220_end,
	oenr.name as oe_prog,
	oenr.startdate as oe_start,
	oenr.enddate as oe_end	
FROM
    dbo.Enrollment enr WITH (NOLOCK)
	INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
	INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
    INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = enr.endyear
    INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
	INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
	LEFT OUTER JOIN dbo.district res_dis WITH (NOLOCK) on res_dis.number = enr.residentdistrict
	LEFT OUTER JOIN dbo.district serv_dis WITH (NOLOCK) on serv_dis.number = enr.servingdistrict
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 289
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) census on census.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 306
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) party on party.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 320
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) payer on payer.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 329
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) sch_override on sch_override.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 317
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) nonres on nonres.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 345
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) trans_dis on trans_dis.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 346
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			) trans_sch on trans_sch.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT cs.enrollmentid, cs.value, cd.name, sch.name as school, dis.number as district_number, dis.name as district_name
		FROM	
			dbo.customstudent cs
			INNER JOIN dbo.campusattribute ca on cs.attributeid = ca.attributeid and ca.attributeid = 677
			INNER JOIN dbo.campusdictionary cd on cd.attributeid = cs.attributeid and cs.value = cd.code
			INNER JOIN dbo.school sch on sch.number = cs.value
			INNER JOIN dbo.district dis on dis.districtid = sch.districtid
			) mpssite on mpssite.enrollmentid = enr.enrollmentid
	LEFT OUTER JOIN 
		(SELECT distinct prgp.personid, prgp.programid, prgp.startdate, prgp.enddate, prg.name 
		FROM
			dbo.ProgramParticipation prgp WITH (NOLOCK)
			INNER JOIN dbo.program prg WITH (NOLOCK) on prg.programID = prgp.programID and prg.programid = '3'
			) chapter on chapter.personid = per.personid 
					and (chapter.startdate <= isnull(enr.enddate, getdate()) and (chapter.enddate is null or chapter.enddate >= enr.startdate))
	LEFT OUTER JOIN 
		(SELECT distinct prgp.personid, prgp.programid, prgp.startdate, prgp.enddate, prg.name 
		FROM
			dbo.ProgramParticipation prgp WITH (NOLOCK)
			INNER JOIN dbo.program prg WITH (NOLOCK) on prg.programID = prgp.programID and prg.programid = '16'
			) oenr on oenr.personid = per.personid 
					and (oenr.startdate <= isnull(enr.enddate, getdate()) and (oenr.enddate is null or oenr.enddate >= enr.startdate))
	LEFT OUTER JOIN 
		(SELECT distinct prgp.personid, prgp.programid, prgp.startdate, prgp.enddate, prg.name 
		FROM
			dbo.ProgramParticipation prgp WITH (NOLOCK)
			INNER JOIN dbo.program prg WITH (NOLOCK) on prg.programID = prgp.programID and prg.programid IN ('22', '23', '24', '25')
			) waiver on waiver.personid = per.personid 
					and (waiver.startdate <= isnull(enr.enddate, getdate()) and (waiver.enddate is null or waiver.enddate >= enr.startdate))
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
WHERE
	 sy.active = 1
	 and cal.exclude <> 1
	 and enr.stateExclude <> 1
	 and (enr.enddate is null or datename(mm, enr.enddate) <> 'July')
--	 and datediff(day, enr.enddate, enr.startdate) < 0
--	 and per.personid = '365429'
--	and UPPER(a.city) <> 'MILWAUKEE'
--	and chapter.name is not null
--and (case when census.value is null then 
--			(case when oenr.name is not null then 'Open Enrollment'
--				when chapter.name is not null then 'Integration Transfer Program C220'
--				when sch.number = '9989' then 'Residential Treatment'
--				when sch.number = '1067' then 's.118.15'
--				when cal.calendarid = '3324' then 'Private School'
--				when waiver.programid = '22' then 'Tuition - Paid'
--				when waiver.programid = '23' then 'Tuition Waiver - Additional Year'
--				when waiver.programid = '24' then 'Tuition Waiver - Current Year' else null end)
--				else census.name end) = 'Integration Transfer Program C220'
	--and sch.name <> 'NON-MPS'
	and nonres.name in ('Open Enrollment')
	and census.name <> 'Open Enrollment'
ORDER BY 
	per.personid, enr.startDate