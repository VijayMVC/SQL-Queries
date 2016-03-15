SELECT
	saa.school_code,
	saa.school_name,
	saax.region,
	fy_attd_1213.attendance_percentage as FY_12_13_Attendance_Rate,
	fy_abs_1213.absentee_rate as FY_12_13_Absenteeism_Rate,
	ytd_attd_1314.attendance_percentage as YTD_13_14_Attendance_Rate,
	ytd_abs_1314.absentee_rate as YTD_13_14_Absenteeism_Rate
FROM
	K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS SAA
	inner join K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT  saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	LEFT OUTER JOIN
(SELECT
    a.SCHOOL_key ,
    round( (sum(a.attendance_value)   /   sum(a.attendance_days) ), 3) as attendance_percentage
FROM
		k12intel_dw.ftbl_attendance_stumonabssum a
WHERE
 	  (a.local_school_year in ('2012-2013'))
group by
 a.school_key) fy_attd_1213   on fy_attd_1213.school_key = saa.school_key
LEFT OUTER JOIN
(SELECT
	ab.school_KEY,
	round (sum (case when ab.absentee = 'Yes' then 1 else 0 end) / count (distinct ab.student_key) , 3)  absentee_rate
FROM
	(SELECT
	  a.STUDENT_key,
	  a.SCHOOL_KEY ,
	  case when ((sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100) <= 84 then 'Yes' else 'No' end as absentee
	  FROM
	  		k12intel_dw.ftbl_attendance_stumonabssum a
	  		inner join K12INTEL_DW.DTBL_STUDENTS_EVOLVED  se on a.student_evolve_key = se.student_evolve_key
	  WHERE
	       se.student_current_grade_code not in ('HS', 'K3', 'K4')  -- only use for accountability
	       and (a.local_school_year in ('2012-2013') )          -- *** enter each school year to export seperately
	GROUP BY
	  		a.STUDENT_key,
	 		a.SCHOOL_key
	having sum(a.attendance_days) >= 45) ab   --commment this out because not for accountability, for action
GROUP BY
ab.school_KEY
) fy_abs_1213 ON FY_ABS_1213.SCHOOL_KEY = SAA.SCHOOL_KEY
LEFT OUTER JOIN
(SELECT
    a.SCHOOL_key ,
    round( (sum(a.attendance_value)   /   sum(a.attendance_days) ) , 3) as attendance_percentage
FROM
		k12intel_dw.ftbl_attendance_stumonabssum a
WHERE
 	  (a.local_school_year in ('2013-2014'))
group by
 a.school_key) ytd_attd_1314   on ytd_attd_1314.school_key = saa.school_key
LEFT OUTER JOIN
(SELECT
	ab.school_KEY,
	round (sum ( case when ab.absentee = 'Yes' then 1 else 0 end) / count (distinct ab.student_key) , 3)  absentee_rate
FROM
	(SELECT
	  a.STUDENT_key,
	  a.SCHOOL_KEY ,
	  case when ((sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100) <= 84 then 'Yes' else 'No' end as absentee
	  FROM
	  		k12intel_dw.ftbl_attendance_stumonabssum a
	  		inner join K12INTEL_DW.DTBL_STUDENTS_EVOLVED  se on a.student_evolve_key = se.student_evolve_key
	  WHERE
	       se.student_current_grade_code not in ('HS', 'K3', 'K4')  -- only use for accountability
	       and (a.local_school_year in ('2013-2014') )          -- *** enter each school year to export seperately
	GROUP BY
	  		a.STUDENT_key,
	 		a.SCHOOL_key
	having sum(a.attendance_days) >= 45) ab   --commment this out because not for accountability, for action
GROUP BY
ab.school_KEY
) ytd_abs_1314 ON ytd_ABS_1314.SCHOOL_KEY = SAA.SCHOOL_KEY
where
	saa.school_year = '2013-2014'
	and saa.reporting_school_ind = 'Y'
order by
3,2
