-- Early grads with first enroll and hs withdrawal date
SELECT
	s.student_id,
	s.student_status,
	s.student_race,
	s.student_gender,
	s.student_age,
	s.student_cumulative_gpa,
	fst.school_code as first_hs,
	fst.student_current_grade_code as first_hs_grade,
	fst.first_hsenroll as first_hs_enroll_dw,
	es.first_registration_date as first_hs_enroll_esis,
	sch.school_code as grad_school_code,
	sch.school_name as grad_school_name,
	s.student_current_grade_code as grad_grade,
	e.withdraw_reason_code,
--	es.diploma_type,
	ed.diploma_name,
	es.diploma_granted_date,
	e.withdraw_date,
--	e.prod_end_enroll_date as enddate,
	sum ((e.prod_end_enroll_date - es.first_registration_date)/365) as Years_in_HS_eSIS,
	sum ((e.prod_end_enroll_date - fst.first_hsenroll)/365) as Years_in_HS_DW
FROM
	K12INTEL_DW.FTBL_ENROLLMENTS e
INNER JOIN	K12INTEL_DW.DTBL_STUDENTS s ON e.student_key = s.student_key
INNER JOIN	K12INTEL_DW.DTBL_SCHOOLS sch ON sch.school_key = e.school_key
INNER JOIN K12INTEL_STAGING.STUDENTS es ON to_char(es.pupil_number) = s.student_id
INNER JOIN K12INTEL_STAGING.DIPLOMAS ed ON es.diploma_type = ed.diploma_type
INNER JOIN	K12INTEL_DW.DTBL_SCHOOL_DATES sdy ON  sdy.school_dates_key = e.school_dates_key_begin_enroll
INNER JOIN
(SELECT
	s.student_id,
	sch.school_code,
	e.enrollment_type,
	sev.student_current_grade_code,
	hs.first_hsenroll
FROM
	K12INTEL_DW.DTBL_STUDENTS s
	INNER JOIN
		(SELECT
			s.student_id,
			min (e.prod_begin_enroll_date) as first_hsenroll
		FROM
			K12INTEL_DW.FTBL_ENROLLMENTS e
			INNER JOIN	K12INTEL_DW.DTBL_STUDENTS s ON e.student_key = s.student_key
			INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED sev ON e.student_evolve_key = sev.student_evolve_key
		WHERE
			e.enrollment_type = 'Actual' and
			sev.student_current_grade_code in ('09')
		GROUP BY
			s.student_id) hs
	ON s.student_id = hs.student_id
	INNER JOIN K12INTEL_DW.FTBL_ENROLLMENTS e ON s.student_key = e.student_key and e.prod_begin_enroll_date = hs.first_hsenroll
	INNER JOIN	K12INTEL_DW.DTBL_SCHOOLS sch ON sch.school_key = e.school_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED sev ON e.student_evolve_key = sev.student_evolve_key) fst
	on s.student_id = fst.student_id
WHERE
		e.withdraw_date > '09-01-2009'
	and	e.withdraw_reason_code = '24'
	and s.student_status = 'Graduate'
	and es.diploma_type not in ('G', 'C', 'CA')
GROUP BY
	s.student_id,
	s.student_status,
	s.student_race,
	s.student_gender,
	s.student_age,
	s.student_cumulative_gpa,
	sch.school_code,
	sch.school_name,
	s.student_current_grade_code,
	e.withdraw_reason_code,
	e.withdraw_date,
	e.prod_end_enroll_date,
	es.diploma_type,
	ed.diploma_name,
	es.diploma_granted_date,
	fst.first_hsenroll,
	es.first_registration_date,
	fst.student_current_grade_code,
	fst.school_code
;


-- First HS enroll using DW enrollment tables
SELECT
	s.student_id,
	sch.school_code,
	e.enrollment_type,
	e.entry_grade_code,
	hs.first_hsenroll
FROM
	K12INTEL_DW.DTBL_STUDENTS s
	RIGHT OUTER JOIN
		(SELECT
			s.student_id,
			min (e.prod_begin_enroll_date) as first_hsenroll
		FROM
			K12INTEL_DW.FTBL_ENROLLMENTS e
			INNER JOIN	K12INTEL_DW.DTBL_STUDENTS s ON e.student_key = s.student_key
			INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd ON e.cal_date_key_begin_enroll = cd.calendar_date_key
-- using only students w/entry grade			INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED sev ON e.student_evolve_key = sev.student_evolve_key
		WHERE
			e.enrollment_type = 'Actual' and
			e.entry_grade_code = '09' and
			cd.month_of_year in ('7','8','9')
		GROUP BY
			s.student_id) hs
	ON s.student_id = hs.student_id
	INNER JOIN K12INTEL_DW.FTBL_ENROLLMENTS e ON s.student_key = e.student_key and e.prod_begin_enroll_date = hs.first_hsenroll
	INNER JOIN	K12INTEL_DW.DTBL_SCHOOLS sch ON sch.school_key = e.school_key
ORDER BY
5;

