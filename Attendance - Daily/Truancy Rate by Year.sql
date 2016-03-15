SELECT
    tot_tru.school_year
    ,tot_tru.grade_level
    ,tot_tru.habitual_truant_students
    ,tot_tru.total_students_served
    ,fall.students as fall_enrollment
FROM
    (SELECT
        truant.school_year
        ,truant.grade_level
        ,count(distinct (case when (truant.sem1_unex >= 5 or truant.sem2_unex >= 5) then truant.student_id else null end)) as habitual_truant_students
        ,count(distinct truant.student_id) as total_students_served
    FROM
        (SELECT
              attd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
              st.STUDENT_ID,
              staa.student_annual_grade_code as grade_level,
              sch.school_code ,
              sum(attd.attendance_days)  as total_membership_days,
              sum(attd.attendance_value)  as att_days,
              sum(attd.attendance_days - attd.attendance_value) as absence_days,
              sum(case when attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else null end) as unex_days,
              round( (sum(attd.attendance_value)   /   sum(attd.attendance_days) ), 3) as attendance_percentage,
              sum(case when cd.month_of_year in (8,9,10,11,12,1) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else 0 end) as sem1_unex,
              sum(case when cd.month_of_year in (2,3,4,5,6) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else null end) as sem2_unex,
              sum(case when cd.month_of_year in (8,9,10,11,12,1) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days else 0 end) as sem1_unex_old,
              sum(case when cd.month_of_year in (2,3,4,5,6) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days else null end) as sem2_unex_old    
        FROM
            k12intel_dw.ftbl_attendance_stumonabssum attd
            INNER JOIN k12intel_dw.dtbl_calendar_dates cd on attd.calendar_date_key  = cd.calendar_date_key
            INNER JOIN k12intel_dw.dtbl_students st on attd.student_key = st.student_key
            INNER JOIN k12intel_dw.dtbl_student_annual_attribs staa on staa.student_key = attd.student_key and staa.school_year = attd.local_school_year
    --        INNER JOIN k12intel_dw.dtbl_students_evolved ste on ste.student_evolve_key = attd.student_evolve_key
            INNER JOIN k12intel_dw.dtbl_schools sch ON sch.school_key = attd.school_key              
        WHERE 1=1
            and attd.local_school_year in ('2010-2011', '2011-2012', '2012-2013', '2013-2014')
        --    and st.student_id = '8625439' 
        GROUP BY
            attd.LOCAL_SCHOOL_YEAR,
            staa.student_annual_grade_code,
            st.STUDENT_ID,
            sch.school_code 
            ) truant
    GROUP BY
        truant.school_year,
        truant.grade_level
        ) tot_tru
    INNER JOIN 
    (SELECT
         count(distinct student_id) as students, 
         student_grade_code as grade_level,
         collection_year as school_year
    FROM
        K12INTEL_DW.MPSD_STATE_AIDS
    WHERE 1=1
        and collection_period = 'September 3rd Friday'
        and collection_year in ('2010-2011', '2011-2012', '2012-2013', '2013-2014')
        and school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE')
        and collection_type = 'PRODUCTION'
        and student_countable_indicator = 'Yes'
    GROUP BY
        student_grade_code,
         collection_year 
            ) fall on fall.grade_level = tot_tru.grade_level and fall.school_year = tot_tru.school_year
WHERE
    tot_tru.grade_level not in ('HS', 'K2', 'K3', 'K4')
ORDER BY 
    1,2