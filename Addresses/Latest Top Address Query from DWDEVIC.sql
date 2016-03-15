-------------------------------------------------------------------------------------
-- Note that this query gets each student's primary address - so it matches the IC Primary Address on the IC Household's Tab:

select distinct student_addresses.*, mai.saa_elem, mai.saa_mid, mai.saa_high    -- into myvars
from
(
 select  distinct
		p.personid as personid,
		sch."NUMBER" as ic_school_code,
	    sch.name as ic_school_name,
	    upper(trim(cal.NAME)) as  CALENDAR_NAME,
		case when hm.personid = rp.personid1 then 0 else 1 end as hm_order,
		nvl(hm.secondary,0) as hm_secondary,
		nvl(hl.secondary,0) as hl_secondary,
		nvl(rp.seq,255) as rp_seq,
		nvl(hm.guardian,0)  as hm_guardian,
		nvl(rp.guardian,0)  as rp_guardian,
		hm.mailing as hm_mailing,
		rp.mailing as rp_mailing,
		rp.name as rp_name,
		a.addressid as addressid,
		a."NUMBER" as street_number,
		trim(upper(a.prefix)) as street_direction,
		trim(upper(a.dir)) as address_dir_not_used,
		trim(upper(a.street)) as street_name,
		trim(upper(a.tag)) as street_type,
		trim(upper(a.apt)) as apartment,
		a.postofficebox as postofficebox,
		a.tract as tract,
		trim(upper(a.city)) as city,
		trim(upper(a.state)) as state,
		a.zip as postal_code,
		a.MAI_RCD_NBR as mai_rcd_nbr,
		p.studentnumber as studentnumber,
		        row_number() over (partition by p.personid
		        order by
		        		-- this is the best priority sort order for kids with multiple addresses (some kids have as many as 6 addresses):
		        		case when a.addressid is null then 0 else 1 end desc,   -- put records with an addressid first so missing/nulls come last
		        		case when hm.personid = rp.personid1 then 0 else 1 end,    -- this puts the enrolled students household records before the relationships
		        		nvl(hm.secondary,0) ,             -- HM secondary asc sort so 0's come first
		        		nvl(hl.secondary,0) ,             -- HL secondary asc sort so 0's come first
		        		nvl(rp.seq,255),                  -- RP SEQ asc sort - this is the freeform "Emergency Priority" entry field which is a tinyint with max value = 255 - Schools are trained to enter 1 for the person to be notified first, then 2 next, etc... and if null then put last ...
		        		nvl(hm.guardian,0) desc,          --HM guardian desc sort so 1 comes before 0
		        		nvl(rp.guardian,0) desc,          -- RP guardian desc sort so 1 comes before 0
		        		hm.mailing desc,                  -- HM mailing desc sort so 1 comes before 0
		        		rp.mailing desc,                  -- RP mailing desc sort so 1 comes before 0
		        		a.postofficebox ,                   -- po box checkbox asc sort so 0s (no po box) come first
		        		a."NUMBER" desc           -- number column from address table desc sort so nulls come last
  				) as addr_sortnum
	from
		k12intel_staging_ic.Person p
			inner join k12intel_staging_ic.enrollment e
				on p.personid = e.personid
			INNER JOIN K12INTEL_STAGING_IC.calendar cal
	                        	ON     e.calendarID = cal.calendarID
	        INNER JOIN K12INTEL_STAGING_IC.School sch
	                        	ON     cal.schoolID = sch.schoolID  AND sch.STAGE_SIS_SCHOOL_YEAR =  2014

			left outer join k12intel_staging_ic.relatedpair rp
				on rp.personid1 = p.personid
						AND (rp.enddate is null or rp.endDate>=trunc(sysdate) )
			LEFT OUTER JOIN k12intel_staging_ic.HouseholdMember hm
				ON (hm.startDate IS NULL OR trunc(hm.startDate) <= trunc(sysdate))
					AND (hm.endDate IS NULL OR trunc(hm.endDate) >= trunc(sysdate))
					AND (hm.personID = p.personID or hm.personid = rp.personid2) 				-- join the enrolled student's personid to HM and the Related-Pair's personid2 to HM  - to get all possible addresses
			LEFT OUTER JOIN k12intel_staging_ic.HouseholdLocation hl
				ON hl.householdID = hm.householdID
					AND (hl.enddate is null OR trunc(hl.endDate) >= trunc(sysdate) )
			LEFT OUTER JOIN k12intel_staging_ic.address a
				on hl.addressid = a.addressid
	where

        -- Current Enrollment:
        e.endyear = 2015 and
        e.startdate <= sysdate  and
        (e.enddate is null or e.enddate >= trunc(sysdate) )

        	-- Exclude non-MPS School Groups 1-8:
			 and (sch."NUMBER" not in ('9986','9987'))          -- exclude 9986-FAMILY SERVICES and 9987-EXPELLED
       		and not (sch."NUMBER"  = '9988' and CAL.NAME like '%PRIVATE%')      -- exclude 9988-PRIVATE sites      (9988-OPEN ENROLLMENT and 9988-CH 220 will get included)
       		and not (sch."NUMBER"  = '9990' and CAL.NAME not like '%EC NON-MPS SITES%')     -- exclude all the 9990 Sites except the 9990-EC NON-MPS SITES site   (412-mps id, 0836-ic id, Special Services Site-ECC is entity name)

--        and
--		(p.StudentNumber in (
--		 '8431008',
--		 '8746615',
--		 '9021996' ,
--		 '9023391'  ,
--		 '9024043'  )
--		 )            -- additional sample sids for testing:  '8377452','358643','8746615','9021996','9023391','9024043'

) student_addresses

			LEFT OUTER JOIN k12intel_staging_ic.mai_address mai           -- left join to mai so get valid milwaukee addresses sorted at top of the list and so doesn't exclude any non-milw or invalid addresses
				ON ( 		(student_addresses.MAI_RCD_NBR = mai.MAI_RCD_NBR)                 -- 1st match on mai_rcd_nbr in mai table
							or
							( student_addresses.city = 'MILWAUKEE' and
							  student_addresses.street_number = mai.HSE_NBR  and
							  student_addresses.street_name = mai.street  and
							  student_addresses.street_direction = mai.dir and
							  student_addresses.street_type = mai.sttype
							)       -- if mai_rcd_nbr not exists, then match on address street #, name, direction, and type to get attendance area schools (saa_elem/mid/high).  Note that don't need to match on zip because these 4 cols always have the same SAA values
					  )
					  and
					  ( nvl(mai.saa_elem,0) <> 0 and nvl(mai.saa_high,0) <> 0 and nvl(mai.saa_mid,0) <> 0 ) -- note that only about 40 records out of 254380 total have a 0 in these 3 cols, and want all 3 filled in

where student_addresses.addr_sortnum = 1
	and student_addresses.city = 'MILWAUKEE'

	--and student_addresses.studentnumber in ('8538049','8503087')

	and mai.saa_elem is null

order by

	student_addresses.mai_rcd_nbr desc,student_addresses.city, street_number,street_direction,street_name, street_type, apartment
	;


-------------------------------------------------------------------------------------------------------------------------------------
-- Here's some good example kids with multiple primaries or no households or multiple relationships:
select studentnumber, personid from person where studentnumber in ('8377452','358643','8746615','9021996','9023391','9024043');


------------------------------------------------------------------------------------------------------------------------------------
-- and here's just another sample kid with multiple addresses:  StudentNumber = 8460483'
select studentnumber, personid from person where studentnumber in ('8460483');


------------------------------------------------------------------------------------------------------------------------------------
-- 3 good sample school current calendars for Hamilton and WCLL:
select * from k12intel_staging_ic.calendar where endyear = 2015 and schoolid =
	(select schoolid from k12intel_staging_ic.school where "NUMBER" = '0018');           -- calendar id = 3252
select * from k12intel_staging_ic.calendar where endyear = 2015 and schoolid =
	(select schoolid from k12intel_staging_ic.school where "NUMBER"  = '0399');         -- calendar id = 3362 for wcll grades 6-12 and 3363 for grades K-5

