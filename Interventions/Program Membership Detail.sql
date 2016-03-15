select
	student_id,
	program_type,
	program_code,
	PROGRAM_Name,
	PROGRAM_GROUP,
	program_subgroup  ,
	bdsd.date_value as begin_date,
	edsd.date_value as end_date,
    prgmx.membership_begin_date,
    prgmx.membership_end_date,
	prgm.*
from
	K12INTEL_DW.DTBL_PROGRAMS prg
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prg.school_key
	inner join k12intel_dw.ftbl_program_membership prgm on prgm.program_key = prg.program_key
    inner join k12intel_dw.FTBL_PROGRAM_MEMBERSHIP_EXT prgmx on prgmx.membership_key = prgm.membership_key
	inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
	inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
	inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
where 1=1
    and st.student_id = '8541244'
--	program_status = 'Active'
----	and dtbl_students.student_activity_indicator = 'Active'
--	and membership_status = 'Active' -- not in ('Expired','Deleted', 'Prior Year Active')
--	and program_type = 'ESL
--	and (program_name like '%Cert%'
--	or program_name like '%GED%' )
--	--sysdate between bdsd.date_value and edsd.date_value
----	program_code in (
----'201',
----'202',
----'311',
----'312',
----'16',
----'575',
----'27',
----'588',
----'584',
----'33',
----'27',
----'200',
----'551',
----'552',
----'553',
----'554',
----'555',
----'556',
----'560'
----)

--group by
--	PROGRAM_Name,
----	sch.school_code,
----	sch.school_name,
--	--st.student_id    ,
--	program_code,
--	program_type,
--	PROGRAM_GROUP,
--	program_subgroup ,
--	membership_status  ,
--	edsd.date_value
----	bdsd.date_value
	order by
	3,7
