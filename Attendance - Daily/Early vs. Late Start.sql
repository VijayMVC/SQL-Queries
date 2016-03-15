SELECT
--  a.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
  sch.school_code,
--  schaa.SCHOOL_CODE ,
--  sum(a.attendance_days)  as total_membership_days,
--  sum(a.attendance_days - a.attendance_value)  as total_absence_days,
  sum(case when a.excused_absence = 'Excused Absence' then a.attendance_days - a.attendance_value else 0 end) as excused_absence_days,
  sum(case when a.excused_absence = 'Un-Excused Absence' or a.excused_absence = 'Unexcused Absence'  then
  				case when a.excused_authorized = 'Yes' then 0 else a.attendance_days - a.attendance_value end
  			else 0 end) as unexcused_absence_days,
  sum(case when absence_reason_code = 'T' then 1 else 0 end) as times_tardy,
  round( (sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100, 2) as attendance_percentage
  FROM
	 k12intel_dw.ftbl_attendance_stumonabssum a
	 INNER JOIN k12intel_dw.dtbl_schools sch on a.school_key = sch.school_key
 WHERE
      sch.school_code in ('20', '29') and
      a.local_school_year in ('2008-2009', '2009-2010', '2010-2011', '2011-2012')
group by
--	a.LOCAL_SCHOOL_YEAR ,
	sch.school_code
order by 2,1;
