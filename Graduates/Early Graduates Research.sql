SELECT
	gr.student_id,
	gr.student_status,
	gr.student_race,
	gr.student_gender,
	gr.student_age,
	gr.student_cumulative_gpa,
	gr.student_graduation_cohort,
	gr.student_1st_grade_cohort,
	gr.school_code,
	 sch.school_name,
	 e.entry_grade_code,
	 sdy.local_school_year,
	sch.school_code,
	e.enrollment_type,
	s.student_current_grade_code,
	e.entry_grade_code,
	min (e.prod_begin_enroll_date) as first_hsenroll,
	e.ENROLLMENT_DAYS,
	e.prod_registration_date as regdate,
	e.withdraw_reason_code,
	e.withdraw_date,
	e.prod_end_enroll_date as enddate,
	s.student_status,
	s.student_activity_indicator
FROM
	K12INTEL_DW.FTBL_ENROLLMENTS e
INNER JOIN	K12INTEL_DW.DTBL_STUDENTS s ON e.student_key = s.student_key
INNER JOIN	K12INTEL_DW.DTBL_SCHOOLS sch ON sch.school_key = e.school_key
INNER JOIN	K12INTEL_DW.DTBL_SCHOOL_DATES sdy ON  sdy.school_dates_key = e.school_dates_key_begin_enroll
INNER JOIN (SELECT
	 s.student_id,
	 s.student_status,
	 s.student_race,
	 s.student_gender,
	 s.student_age,
	 s.student_cumulative_gpa,
	 s.student_graduation_cohort,
	 s.student_1st_grade_cohort,
	 sch.school_code,
	 sch.school_name,
	 e.entry_grade_code,
	 s.student_current_grade_code,
	 e.withdraw_date,
	 e.withdraw_reason_code
FROM
	K12INTEL_DW.FTBL_ENROLLMENTS e
	INNER JOIN  K12INTEL_DW.DTBL_STUDENTS s
		ON e.student_key = s.student_key
	INNER JOIN	K12INTEL_DW.DTBL_SCHOOLS sch
		ON e.school_key = sch.school_key
WHERE
	e.withdraw_date > '09-01-2009'
and	e.withdraw_reason_code = '24'
and s.student_status = 'Graduate'
ORDER BY
s.student_age ) gr
 ON gr.student_id = s.student_id
WHERE
--	sdy.sis_school_year in (2010, 2011, 2012) and
	e.enrollment_type = 'Actual' and
	e.entry_grade_code = '09'
GROUP BY
	gr.student_id,
	gr.student_status,
	gr.student_race,
	gr.student_gender,
	gr.student_age,
	gr.student_cumulative_gpa,
	gr.student_graduation_cohort,
	gr.student_1st_grade_cohort,
	gr.school_code,
	sdy.local_school_year,
	s.student_id,
	sch.school_code,
	e.enrollment_type,
	s.student_current_grade_code,
	e.entry_grade_code,
	e.ENROLLMENT_DAYS,
	e.prod_registration_date,
	e.withdraw_reason_code,
	e.withdraw_date,
	e.prod_end_enroll_date,
	s.student_status,
	s.student_activity_indicator,
	sch.school_name
Order by
1  ;


