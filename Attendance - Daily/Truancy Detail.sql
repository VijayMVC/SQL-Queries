SELECT
	  attd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	  st.STUDENT_ID,
      st.student_gender,
      st.student_race,
      sch.school_code as mps_school_code,
      schx.school_state_id,
      sch.school_name,
      staa.student_annual_grade_code,
	  sum(attd.attendance_days)  as total_membership_days,
	  sum(attd.attendance_value)  as att_days,
      sum(attd.attendance_days - attd.attendance_value) as absence_days,
      sum(case when attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else null end) as unex_days,
	  round( (sum(attd.attendance_value)   /   sum(attd.attendance_days) ), 3) as attendance_percentage,
      sum(case when cd.month_of_year in (8,9,10,11,12,1) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else 0 end) as sem1_unex,
      sum(case when cd.month_of_year in (2,3,4,5,6) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else null end) as sem2_unex     
FROM
	k12intel_dw.ftbl_attendance_stumonabssum attd
    INNER JOIN k12intel_dw.dtbl_calendar_dates cd on attd.calendar_date_key  = cd.calendar_date_key
    INNER JOIN k12intel_dw.dtbl_students st on attd.student_key = st.student_key
    INNER JOIN k12intel_dw.dtbl_student_annual_attribs staa on staa.student_annual_attribs_key = attd.student_annual_attribs_key
	INNER JOIN k12intel_dw.dtbl_schools sch ON sch.school_key = attd.school_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key  			
WHERE 1=1
	and attd.local_school_year = '2014-2015'
    and exists 
        (select 1
        from K12INTEL_STAGING_MPSENT.SCH_GRADES_JOIN sg
            INNER JOIN K12INTEL_STAGING_MPSENT.SCH_GRADES_DEF gd on sg.sch_grades_def_key = gd.key
            INNER JOIN K12INTEL_STAGING_MPSENT.ENT_ENTITY_MASTER_VIEW ent on ent.entity_id = sg.entity_id 
                                                                            and ent.school_year_fall = sg.school_year_fall
                                                                            and ent.school_year_fall = 2014
       WHERE to_char(ENT.ESIS_ID) = sch.school_code
             and staa.student_annual_grade_code = gd.esis_code)
--    and st.student_id = '8625439' 
GROUP BY
    attd.LOCAL_SCHOOL_YEAR,
    staa.student_annual_grade_code,
    st.STUDENT_ID,
      st.student_gender,
      st.student_race,
      sch.school_code,
      schx.school_state_id,
      sch.school_name
--    sch.school_code
HAVING
    sum(case when cd.month_of_year in (8,9,10,11,12,1) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else 0 end) > 4.5
   OR   sum(case when cd.month_of_year in (2,3,4,5,6) and attd.excused_absence IN ('Unexcused Absence','Un-Excused Absence','Unexcused') then attd.attendance_days - attd.attendance_value else null end) > 4.5     
ORDER BY 1
;
select * from k12intel_staging_mpsent.sch_grades_join