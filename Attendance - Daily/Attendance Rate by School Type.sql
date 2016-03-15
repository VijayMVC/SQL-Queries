SELECT
	sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
	sum(a.attendance_days)  as total_membership_days,
	sum(a.attendance_days - a.attendance_value)  as total_absence_days,
--    case when substr(schaa.school_current_grades,1,1) in ('K', 'H') then 'Elementary'
--        when schaa.school_current_grades = '06 - 08' then 'Middle'
--        when (substr(schaa.school_current_grades,1,1) in ('K', 'H') and instr(schaa.school_current_grades, '12') > 1) then 'Elementary'
--        when instr(schaa.school_current_grades, '12') > 1 then 'High School'
--        else 'Elementary' end as school_type,
	round( (sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100, 2) as attendance_percentage
FROM
	k12intel_dw.ftbl_attendance_stumonabssum a
	INNER JOIN k12intel_dw.dtbl_calendar_dates c on  a.calendar_date_key  = c.calendar_date_key
	INNER JOIN k12intel_dw.dtbl_schools s on a.school_key = s.school_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_annual_attribs_key = a.school_annual_attribs_key
	INNER JOIN k12intel_dw.dtbl_schools_extension sx on s.school_key = sx.school_key
	INNER JOIN k12intel_dw.dtbl_students st on a.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on a.school_dates_key = sd.school_dates_key
WHERE
	(sd.local_school_year in ('2013-2014'))
    and schaa.reporting_school_ind = 'Y'
--	and s.school_code in ('89', '220', '667', '25', '432')
group by
	sd.LOCAL_SCHOOL_YEAR
--	case when substr(schaa.school_current_grades,1,1) in ('K', 'H') then 'Elementary'
--        when schaa.school_current_grades = '06 - 08' then 'Middle'
--        when (substr(schaa.school_current_grades,1,1) in ('K', 'H') and instr(schaa.school_current_grades, '12') > 1) then 'Elementary'
--        when instr(schaa.school_current_grades, '12') > 1 then 'High School'
--        else 'Elementary' end
order by 3,1;


