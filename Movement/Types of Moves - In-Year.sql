SELECT
	ste.student_id,
	reg_sd.local_school_year,
	schaa.school_code,
	to_char(reg_sd.date_value, 'MM/DD/YYYY') as enter_date,
	case when reg_sd.local_enroll_day_in_school_yr >= 10 then 1 else 0 end as Entering,
	to_char(end_sd.date_value, 'MM/DD/YYYY') as end_date,
	case when enr.withdraw_date is not null and end_sd.local_enroll_day_in_school_yr <= 160 then 1 else 0 end as Exiting,
	sum(case when enr.withdraw_date is null
		then 175 - reg_sd.local_enroll_day_in_school_yr
		else end_sd.local_enroll_day_in_school_yr - reg_sd.local_enroll_day_in_school_yr
		end) as enrollment_days,
	count(*) as enrollment_count
FROM
  K12INTEL_DW.FTBL_ENROLLMENTS enr
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED STE ON enr.student_evolve_key = ste.student_evolve_key
  			INNER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS STD on std.student_key = ste.student_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  reg_sd on enr.school_dates_key_register=reg_sd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_key = enr.school_key and reg_sd.local_school_year = schaa.school_year
  															--schaa.school_annual_attribs_key = enr.school_annual_attribs_key
WHERE
	reg_sd.local_school_year in ('2012-2013')
 	and enr.enrollment_type = 'Actual'
 	and schaa.reporting_school_ind = 'Y'
	--and ste.student_id in ( '8520682')
GROUP BY
	ste.student_id,
	reg_sd.date_value,
	reg_sd.local_enroll_day_in_school_yr,
	end_sd.date_value,
	enr.withdraw_date,
	end_sd.local_enroll_day_in_school_yr,
	reg_sd.local_school_year,
	schaa.school_code
HAVING
	sum(case when enr.withdraw_date is null
		then 175 - reg_sd.local_enroll_day_in_school_yr
		else end_sd.local_enroll_day_in_school_yr - reg_sd.local_enroll_day_in_school_yr
		end) > 5
ORDER BY
	3
;
SELECT
	moves.student_id,
	count (distinct moves.school_code),
	sum moves.entering as in_takes,
	sum moves.exiting as exits
	avg(moves.enrollment_days),
	sum moves.enrollment_count as total_enrollments
FROM
	(SELECT
		ste.student_id,
		reg_sd.local_school_year,
		schaa.school_code,
		to_char(reg_sd.date_value, 'MM/DD/YYYY') as enter_date,
		case when reg_sd.local_enroll_day_in_school_yr >= 10 then 1 else 0 end as Entering,
		to_char(end_sd.date_value, 'MM/DD/YYYY') as end_date,
		case when enr.withdraw_date is not null and end_sd.local_enroll_day_in_school_yr <= 160 then 1 else 0 end as Exiting,
		sum(case when enr.withdraw_date is null
			then 175 - reg_sd.local_enroll_day_in_school_yr
			else end_sd.local_enroll_day_in_school_yr - reg_sd.local_enroll_day_in_school_yr
			end) as enrollment_days,
		count(*) as enrollment_count
	FROM
	  K12INTEL_DW.FTBL_ENROLLMENTS enr
	  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED STE ON enr.student_evolve_key = ste.student_evolve_key
	  			INNER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS STD on std.student_key = ste.student_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  reg_sd on enr.school_dates_key_register=reg_sd.school_dates_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_key = enr.school_key and reg_sd.local_school_year = schaa.school_year
	  															--schaa.school_annual_attribs_key = enr.school_annual_attribs_key
	WHERE
		reg_sd.local_school_year in ('2012-2013')
	 	and enr.enrollment_type = 'Actual'
	 	and schaa.reporting_school_ind = 'Y'
		--and ste.student_id in ( '8520682')
	GROUP BY
		ste.student_id,
		reg_sd.date_value,
		reg_sd.local_enroll_day_in_school_yr,
		end_sd.date_value,
		enr.withdraw_date,
		end_sd.local_enroll_day_in_school_yr,
		reg_sd.local_school_year,
		schaa.school_code
	HAVING
		sum(case when enr.withdraw_date is null
			then 175 - reg_sd.local_enroll_day_in_school_yr
			else end_sd.local_enroll_day_in_school_yr - reg_sd.local_enroll_day_in_school_yr
			end) > 5
	ORDER BY
		3  ) MOVES
