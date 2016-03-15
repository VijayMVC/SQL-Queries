-- DDW Grads by date
SELECT distinct
    schaa.school_name,
    count(distinct s.student_id) as graduates
--	s.student_id,
--	s.student_status,
--	s.student_race,
--	s.student_gender,
--	s.student_age,
--	s.student_cumulative_gpa,
--    s.student_special_ed_indicator,
--	schAA.school_code as grad_school_code,
--	schAA.school_name as grad_school_name
--	s.student_current_grade_code as grad_grade,
--	e.withdraw_reason_code,
--	grad.diplomatype,
--	e.withdraw_date,
--	row_number() over (partition by s.student_id order by e.withdraw_date)
FROM
	K12INTEL_DW.FTBL_ENROLLMENTS e
	INNER JOIN	K12INTEL_DW.DTBL_STUDENTS s ON e.student_key = s.student_key
	INNER JOIN	K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa ON schaa.school_annual_attribs_key = e.school_annual_attribs_key
--	INNER JOIN K12INTEL_STAGING.STUDENTS es ON to_char(es.pupil_number) = s.student_id
--	INNER JOIN K12INTEL_STAGING.DIPLOMAS ed ON es.diploma_type = ed.diploma_type
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sdy ON  sdy.school_dates_key = e.school_dates_key_begin_enroll
	INNER JOIN K12INTEL_STAGING_IC.PERSON per on per.studentnumber = s.student_id
	INNER JOIN K12INTEL_STAGING_IC.GRADUATION GRAD ON  grad.personid = per.personid
WHERE
		e.withdraw_date < to_date('09-01-2015', 'MM-DD-YYYY')
	and e.withdraw_date > to_date('08-30-2014', 'MM-DD-YYYY')
	and	e.withdraw_reason_code = 'HSC'
	and schaa.reporting_school_ind = 'Y'
	and e.home_or_cross_enrollment = 'Home School'
--	and grad.diplomatype = 'C'   -- 46 with C
group by
--    schAA.school_code,
    schAA.school_name
order by 1
--	s.student_id
;

