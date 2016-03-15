SELECT 
        st.student_id,
        SD.DATE_VALUE,
        ATTD.*
--        COUNT(attd.ATTENDANCE_KEY),
--        SUM(ATTENDANCE_VALUE),
--        COUNT(attd.ATTENDANCE_KEY) - SUM(ATTENDANCE_VALUE)
    FROM
        k12intel_dw.dtbl_students st
        INNER JOIN k12intel_dw.ftbl_attendance  attd on attd.student_key = st.student_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = attd.school_dates_key
        
    WHERE 1=1  
        and st.student_id = '7855346'
        and sd.local_school_year = '2013-2014'
        and attd.excused_absence IN ('Unexcused Absence',
                                     'Un-Excused Absence',
                                     'Unexcused')
    and exists 
    (SELECT
        daa.student_id
        ,truant.*
    FROM
           (select distinct student_id as student_id from daaadmin.TRUANT_detail
            where year = 2013 and grade not in ('HS', 'K2', 'K3', 'K4') ) daa 
        LEFT OUTER JOIN
        (SELECT 
            st1.student_id,
            attd.local_school_year as school_year,
            attd.Local_semester,
            sum(attd.attendance_days - attd.attendance_value) as absences
        FROM
            k12intel_dw.dtbl_students st1
            INNER JOIN k12intel_dw.ftbl_attendance_stumonabssum attd on attd.student_key = st1.student_key
        WHERE 1=1
            and attd.local_school_year = '2013-2014'
            and attd.excused_absence IN ('Unexcused Absence',
                                         'Un-Excused Absence',
                                         'Unexcused')
        GROUP BY 
            st1.student_id,
           attd.local_school_year,
            attd.Local_semester
        HAVING sum(attd.attendance_days - attd.attendance_value) > 4.5 ) truant on daa.student_id = truant.student_id
     WHERE 1=1
        AND truant.student_Id is null
        and daa.student_id = st.student_id )
--GROUP BY 
--       st.student_id.
--       SD.DATE_VAL
order by 1,2