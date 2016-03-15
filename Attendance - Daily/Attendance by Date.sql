SELECT
 --   st.student_id,
    sch.school_code,
    sch.school_name,  
--    cd.day_name_short,
--    cd.date_value,
   round( (sum(attd.attendance_value)   /   count(attd.attendance_key) ) * 100, 2) as attendance_percentage
--    attd.*
FROM
    k12intel_dw.ftbl_attendance attd
    INNER JOIN K12INTEL_dw.dtbl_students st on st.student_key = attd.student_key
    INNER JOIN k12intel_dw.dtbl_schools sch ON sch.school_key = attd.school_key
    INNER JOIN k12intel_dw.dtbl_schools_extension sx on sx.school_key = sch.school_key
    INNER JOIN k12intel_dw.dtbl_calendar_dates cd on attd.calendar_date_key  = cd.calendar_date_key
WHERE 1=1
--    and st.student_id = '8633491'
    and cd.date_value >=  to_date('09-08-2015', 'MM-DD-YYYY') 
--    or cd.date_value =  to_date('01-23-2014', 'MM-DD-YYYY') 
--    or cd.date_value =  to_date('01-24-2014', 'MM-DD-YYYY') 
--    or cd.date_value =  to_date('06-11-2014', 'MM-DD-YYYY') 
--    or cd.date_value =  to_date('06-12-2014', 'MM-DD-YYYY') 
--    or cd.date_value =  to_date('06-13-2014', 'MM-DD-YYYY') 
 --   and sch.school_code in ('14', '18', '69', '29', '32', '33')
GROUP BY
    sch.school_code,
    sch.school_name  
--    cd.day_name_short,
--    cd.date_value,
--    st.student_id
ORDER BY 1
