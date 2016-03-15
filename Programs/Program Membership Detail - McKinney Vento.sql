select --count (distinct student_id)
    student_id,
    prgm.membership_key
    program_type,
    program_code,
    PROGRAM_Name,
    PROGRAM_GROUP,
    program_subgroup  ,
    prgm.membership_entry_reasons,
    prgm.membership_status,
    sch.school_code,
    sch.school_name,
    bdsd.date_value as begin_date,
    edsd.date_value as end_date,
    prgmx.membership_begin_date,
    prgmx.membership_end_date,
    prgm.*
from
    K12INTEL_DW.DTBL_PROGRAMS prg
    inner join k12intel_dw.ftbl_program_membership prgm on prgm.program_key = prg.program_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
    inner join k12intel_dw.FTBL_PROGRAM_MEMBERSHIP_EXT prgmx on prgmx.membership_key = prgm.membership_key
    inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
    inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
    inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
where 1=1
    and program_name = 'McKinney Vento'
    and bdsd.date_value >= to_date('07-01-2015', 'MM-DD-YYYY') 
--    and edsd.date_value <= to_date('06-25-2016', 'MM-DD-YYYY')
--    and st.student_id = '9000601'
order by
   1
;
select
    count (distinct st.student_key) as students
from
    K12INTEL_DW.DTBL_PROGRAMS prg
    inner join k12intel_dw.ftbl_program_membership prgm on prgm.program_key = prg.program_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
    inner join k12intel_dw.FTBL_PROGRAM_MEMBERSHIP_EXT prgmx on prgmx.membership_key = prgm.membership_key
    inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
    inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
    inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
where 1=1
    and program_name = 'McKinney Vento'
    and bdsd.date_value >= to_date('07-01-2015', 'MM-DD-YYYY') 
--    and edsd.date_value <= to_date('06-25-2014', 'MM-DD-YYYY')
--    and st.student_id = '9000601'
order by
   1
;
SELECT DISTINCT PROGRAM_NAME FROM K12INTEL_DW.DTBL_PROGRAMS WHERE PROGRAM_NAME LIKE 'M%' ORDER BY 1
;
select * from k12intel_dw.dtbl_school_annual_attribs where school_annual_attribs_key = 39867 --37098 --