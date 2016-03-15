SELECT
    staa.school_year,
-- 'All Students' as Category,    
--     st.student_gender,
--  staa.student_race,
    staa.student_special_ed_indicator,
--   staa.student_esl_indicator,
--Enrollment counts
  count(distinct attd.student_annual_attribs_key) as total_served,
  round(sum(case when staa.student_foodservice_indicator = 'Yes' then 1 else 0 end)/count(distinct attd.student_annual_attribs_key),3) as pct_frl,
  round(sum(case when staa.student_special_ed_indicator = 'Yes' then 1 else 0 end)/count(distinct attd.student_annual_attribs_key),3) as pct_sped,    
--Attendance rates for last three years
    round(sum(attd.attendance_days)/sum(attd.membership_days), 3) as attendance_rate,
--Suspensions for last three years
	count(susp.student_annual_attribs_key) as suspended_students,
    round(count(susp.student_annual_attribs_key)/count(distinct attd.student_annual_attribs_key), 3) as suspension_rate
FROM
    K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = staa.student_key
    INNER JOIN	( select
				a.student_annual_attribs_key,
                sum(a.attendance_value) as attendance_days,
                sum(a.attendance_days) as membership_days
			 from
			  	K12INTEL_DW.FTBL_ATTENDANCE_STUMONABSSUM  a
                INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on a.school_annual_attribs_key = schaa.school_annual_attribs_key
			 WHERE
			       schaa.reporting_school_ind = 'Y'
			 group by
		 	    a.student_annual_attribs_key) attd on attd.student_annual_attribs_key = staa.student_annual_attribs_key
	LEFT OUTER JOIN
		 	( select distinct
				da.student_annual_attribs_key
			 from
			  	K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da
                INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = da.school_dates_key
			 WHERE
                da.discipline_action_type = 'Suspension'
                ) susp on staa.student_annual_attribs_key = susp.student_annual_attribs_key
WHERE
    staa.school_year in ('2011-2012', '2012-2013', '2013-2014')
GROUP BY
    staa.school_year,
--    st.student_gender
    staa.student_special_ed_indicator
--    staa.student_esl_indicator
--    staa.student_race
ORDER BY 
    1