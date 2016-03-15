SELECT
	st.student_id,
	listed_sch.school_code,
	listed_sch.school_name,
	all_enr.grade_group,
	all_enr.first_enroll_date,
	all_enr.first_enroll_year,
	all_enr.end_enroll_date,
	all_enr.end_enroll_year,
	sum(case when attd.school_key = all_enr.school_key then attd.attendance_days else null end) as listed_member_days,
	round(sum(case when attd.school_key = all_enr.school_key then attd.attendance_value else null end) / sum(case when attd.school_key = all_enr.school_key then attd.attendance_days else null end),3) as listed_attd_rate,
    max(listed_disc.referrals) as listed_referrals,
    max(listed_disc.suspensions) as listed_suspensions,
    max(listed_marks.credits) as listed_credits,
    max(listed_marks.gpa) as listed_gpa,
	prev_sch.school_code as prev_school_code,
	prev_sch.school_name as prev_school,
	sum(case when attd.school_key = all_enr.previous_school_key then attd.attendance_days else null end) as prev_member_days,
	round(sum(case when attd.school_key = all_enr.previous_school_key then attd.attendance_value else null end) / sum(case when attd.school_key = all_enr.previous_school_key then attd.attendance_days else null end),3) as listed_attd_rate,
	max(prev_disc.referrals) as prev_referrals,
	max(prev_disc.suspensions) as prev_suspensions,
	max(prev_marks.credits) as prev_credits,
    max(prev_marks.gpa) as prev_gpa
FROM
	K12INTEL_DW.DTBL_STUDENTS st
	INNER JOIN
		(SELECT
			st.student_key,
			schaa.school_key,
			case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
				when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
				else 'ELEM' END as grade_group,
			min(adm_cd.date_value) as first_enroll_date,
			min(adm_sd.local_school_year) as first_enroll_year,
			max(wd_cd.date_value) as end_enroll_date,
			max(wd_sd.local_school_year) as end_enroll_year,
			DENSE_RANK() OVER (PARTITION BY st.student_key, schaa.school_key, case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
				when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
				else 'ELEM' END ORDER BY min(adm_cd.date_value) )  as enrollment_num,
			LEAD(schaa.school_key,1) OVER (PARTITION BY st.student_key, case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
				when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
				else 'ELEM' END ORDER BY min(adm_cd.date_value) desc )  as previous_school_key
		FROM
			K12INTEL_DW.FTBL_ENROLLMENTS enr
			INNER JOIN k12intel_dw.dtbl_students ST ON ST.STUDENT_KEY = enr.student_key
			INNER JOIN K12INTEL_DW.DTBL_student_annual_attribs STAA ON enr.student_annual_attribs_key = staa.student_annual_attribs_key
			INNER JOIN k12intel_dw.dtbl_calendar_dates adm_cd on enr.cal_date_key_register = adm_cd.calendar_date_key
			INNER JOIN k12intel_dw.dtbl_calendar_dates wd_cd on enr.cal_date_key_end_enroll = wd_cd.calendar_date_key
			INNER JOIN k12intel_dw.dtbl_school_dates adm_sd on enr.school_dates_key_register = adm_sd.school_dates_key
			INNER JOIN k12intel_dw.dtbl_school_dates wd_sd on enr.school_dates_key_end_enroll = wd_sd.school_dates_key
			INNER JOIN K12Intel_DW.Dtbl_School_annual_attribs schaa ON enr.school_annual_attribs_key = schaa.school_annual_attribs_key
			INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx ON enr.SCHOOL_KEY =  schx.school_KEY
		WHERE
			enr.enrollment_days > 39
			and st.student_key <> 0
			and schaa.reporting_school_ind = 'Y'
--			and st.student_id = '8746234'
		GROUP BY
			st.student_key,
			st.student_id,
			schaa.school_key,
			case when staa.student_annual_grade_code in ('09', '10', '11', '12') then 'HS'
				when staa.student_annual_grade_code in ('06', '07', '08') then 'MS'
				else 'ELEM' END
		ORDER BY
			st.student_key )   all_enr  on all_enr.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS listed_sch on all_enr.school_key = listed_sch.school_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS prev_sch on all_enr.previous_school_key = prev_sch.school_key
	INNER JOIN K12INTEL_DW.FTBL_ATTENDANCE_STUSUMMARY attd on attd.student_key = st.student_key
																	and attd.local_school_year <= '2014-2015'

	LEFT OUTER JOIN
		(SELECT
			d.student_key,
			d.school_key,
			count(d.discipline_key) as referrals,
			count(da.discipline_action_key) as suspensions
		FROM
			K12INTEL_DW.FTBL_DISCIPLINE d
			INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on d.school_dates_key = sd.school_dates_key  and sd.local_school_year <= '2014-2015'
			LEFT OUTER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key and da.discipline_action_type = 'Suspension'
		GROUP BY
			d.student_key,
			d.school_key)
			listed_disc on listed_disc.student_key = st.student_key and listed_disc.school_key = all_enr.school_key

	 LEFT OUTER JOIN
		(SELECT
			d.student_key,
			d.school_key,
			count(d.discipline_key) as referrals,
			count(da.discipline_action_key) as suspensions
		FROM
			K12INTEL_DW.FTBL_DISCIPLINE d
			INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on d.school_dates_key = sd.school_dates_key and sd.local_school_year <= '2014-2015'
			LEFT OUTER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key and da.discipline_action_type = 'Suspension'
		GROUP BY
			d.student_key,
			d.school_key)
			prev_disc on prev_disc.student_key = st.student_key and prev_disc.school_key = all_enr.previous_school_key
	LEFT OUTER JOIN
		(SELECT
			fm.student_key,
			fm.school_key,
			sum(fm.mark_credit_value_earned) as credits,
			round (sum (fm.mark_credit_value_earned * fm.mark_numeric_value) / nullif(sum(fm.mark_credit_value_attempted),0), 3) as GPA
		FROM
			K12INTEL_DW.FTBL_STUDENT_MARKS fm
			INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key  and sd.local_school_year <= '2014-2015'
		WHERE
			fm.mark_type = 'Final'
		GROUP BY
			fm.student_key,
			fm.school_key )
			listed_marks on listed_marks.student_Key = st.student_key and listed_marks.school_key = all_enr.school_key
						and all_enr.grade_group = 'HS'

     LEFT OUTER JOIN
		(SELECT
			fm.student_key,
			fm.school_key,
			sum(fm.mark_credit_value_earned) as credits,
			round (sum (fm.mark_credit_value_earned * fm.mark_numeric_value) / nullif(sum(fm.mark_credit_value_attempted),0), 3) as GPA
		FROM
			K12INTEL_DW.FTBL_STUDENT_MARKS fm
			INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key  and sd.local_school_year <= '2013-2014'
		WHERE
			fm.mark_type = 'Final'
		GROUP BY
			fm.student_key,
			fm.school_key )
			prev_marks on prev_marks.student_Key = st.student_key and prev_marks.school_key = all_enr.previous_school_key
						and all_enr.grade_group = 'HS'

WHERE
	all_enr.enrollment_num = 1
	and (all_enr.first_enroll_year <=  '2014-2015' and all_enr.end_enroll_year >= '2014-2015' )
	and all_enr.previous_school_key is not null
GROUP BY
	st.student_id,
	listed_sch.school_code,
	listed_sch.school_name,
	all_enr.school_key,
	all_enr.grade_group,
	all_enr.first_enroll_date,
	all_enr.first_enroll_year,
	all_enr.end_enroll_date,
	all_enr.end_enroll_year,
	all_enr.previous_school_key,
	prev_sch.school_code,
	prev_sch.school_name
ORDER BY
	st.student_id,
	all_enr.first_enroll_date desc
;
