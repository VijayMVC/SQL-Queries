select --count (distinct student_id)
	student_id,
	program_type,
	program_code,
	PROGRAM_Name,
	PROGRAM_GROUP,
	program_subgroup  ,
    prgm.membership_entry_reasons,
    prgm.membership_status,
	bdsd.date_value as begin_date,
	edsd.date_value as end_date,
    prgmx.membership_begin_date,
    prgmx.membership_end_date
from
	K12INTEL_DW.DTBL_PROGRAMS prg
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prg.school_key
	inner join k12intel_dw.ftbl_program_membership prgm on prgm.program_key = prg.program_key
    inner join k12intel_dw.FTBL_PROGRAM_MEMBERSHIP_EXT prgmx on prgmx.membership_key = prgm.membership_key
	inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
	inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
	inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
where 1=1
	and program_name = 'TABS'
    and prgmx.membership_begin_date >= to_date('07-01-2015', 'MM-DD-YYYY')
--    and prgmx.membership_end_date <= to_date('06-25-2016', 'MM-DD-YYYY')
order by
	1
;
SELECT DISTINCT PROGRAM_NAME FROM K12INTEL_DW.DTBL_PROGRAMS WHERE PROGRAM_NAME LIKE 'T%' ORDER BY 1