SELECT
	s.pupil_number,
	s.grade,
	s.first_registration_date,
	s.diploma_granted_date,
	s.diploma_issued,
	cr.years_on_transcript,
	s.rank_school as grad_school,
	s.school,
	s.diploma_type,
	d.diploma_name,
	s.rank_1,
	s.rank_total
FROM
	ADMASSIST.STUDENTS s
	INNER JOIN	ADMASSIST.DIPLOMAS  d  ON s.diploma_type = d.diploma_type
	INNER JOIN  ADMASSIST.CREDITS c ON c.pupil_number = s.pupil_number
	INNER JOIN
	(SELECT
		c.pupil_number,
		count (distinct year) as years_on_transcript
	FROM
		ADMASSIST.CREDITS c
	WHERE
		grade in (null, '09', '10', '11', '12') and
		(high_school_credit = 'Y'
		or include_in_gpa = 'Y'
		or include_in_ranking = 'Y')
	GROUP BY
		pupil_number) cr
    ON cr.pupil_number = s.pupil_number
WHERE
   diploma_granted_date >  '09-01-2009'
   and withdraw_code = '24'
   and c.school <> '9999'

