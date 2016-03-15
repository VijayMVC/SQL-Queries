
SELECT
  sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
  st.STUDENT_ID,
  st.student_name,
  staa.student_annual_grade_code,
--  st.student_status,
--  s.SCHOOL_CODE ,
--  s.school_name,
  sum(a.attendance_days)  as total_membership_days,
  sum(a.attendance_days - a.attendance_value)  as total_absence_days,
  sum(case when a.excused_absence in ('Excused Absence', 'Excused') then a.attendance_days - a.attendance_value else 0 end) as excused_absence_days,
  sum(case when a.excused_absence in ('Un-Excused Absence', 'Unexcused Absence', 'Unexcused')  then
  				case when a.excused_authorized = 'Yes' then 0 else a.attendance_days - a.attendance_value end
  			else 0 end) as unexcused_absence_days,
  sum(case when absence_reason_code = 'T' then 1 else 0 end) as times_tardy,
  round( (sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100, 2) as attendance_percentage
  FROM
  		k12intel_dw.ftbl_attendance_stumonabssum a,
        k12intel_dw.dtbl_student_annual_attribs staa,
        k12intel_dw.dtbl_school_annual_attribs schaa,
       k12intel_dw.dtbl_calendar_dates c,
       k12intel_dw.dtbl_schools s,
       k12intel_dw.dtbl_students st,
       K12INTEL_DW.DTBL_SCHOOL_DATES sd
 WHERE
       a.calendar_date_key  = c.calendar_date_key
       and staa.student_annual_attribs_key = a.student_annual_attribs_key
       and a.school_annual_attribs_key = schaa.school_annual_attribs_key
       and a.school_dates_key = sd.school_dates_key
       AND a.school_key = s.school_key
       AND a.student_key = st.student_key
       and staa.student_annual_grade_code in ('K3', 'K4', 'K5')
       and schaa.reporting_school_ind = 'Y'
       and a.local_school_year = '2014-2015'
--       and s.school_code = '678'
--       and st.student_activity_indicator = 'Active'
--       and (sd.local_school_year >= '2012-2013' )                   -- *** enter each school year to export seperately
--      AND (st.student_id in ('8167621'))
group by
  sd.LOCAL_SCHOOL_YEAR ,
  staa.student_annual_grade_code,
  st.STUDENT_ID,
  st.student_status,
  st.student_name
-- s.SCHOOL_CODE
order by 2,3;
