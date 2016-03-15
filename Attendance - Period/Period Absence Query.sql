SELECT
    st.student_id,
    st.student_key,
    sch.school_code,
    sch.school_name,
    pa.course_offerings_key,
    co.course_offerings_key,
    co.course_section_name,
    co.course_period,
    co.course_section_days,
    sd.date_value,
    pa.attendance_type,
    pa.absence_reason_code,
    pa.absence_reason,
    pa.instructional_minutes,
    pa.attendance_minutes,
    pa.classroom_attendance_minutes 
FROM
    K12INTEL_DW.FTBL_PERIOD_ABSENCES pa
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = pa.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = pa.school_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = pa.student_key
    INNER JOIN K12INTEL_DW.DTBL_COURSE_OFFERINGS co on co.course_offerings_key = pa.course_offerings_key
WHERE 1=1
--    and st.student_id = '8532805'
    and sch.school_code = '176'
--    and co.course_section_name like 'HMRM%'
    and co.course_period = '01'
--    and sd.date_value = to_date('9-25-2015','MM-DD-YYYY')
--    and instr(co.course_section_name, 'Section: 9') > 0
    and co.course_offerings_key = 1240800
ORDER BY
    sd.date_value,
    co.course_period
 
;
select * from k12intel_dw.dtbl_students where student_name like 'Hall, Destiny%'