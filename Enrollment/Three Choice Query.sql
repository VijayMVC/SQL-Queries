SELECT
	sch.school_code,
	sch.school_name,
	one.school_year,
	one.students as first_choice_students,
	two.students as second_choice_students,
	three.students as third_choice_students
FROM
	K12INTEL_DW.DTBL_SCHOOLS sch
	LEFT OUTER JOIN
	(SELECT
		tre.school_choice_1 as school,
	 	count(distinct tre.pupil_number) as students,
	 	extract(year from tre.start_date) as school_year
	FROM
		K12INTEL_STAGING.MPS_SAP_STUDENT_3CHOICE tre
	WHERE
		tre.school_choice_1 in ('116', '212', '270', '615', '194', '325', '312', '149', '42', '4', '399', '664')
		and extract(year from tre.start_date)  in ('2013', '2014')
	GROUP BY
		tre.school_choice_1,
		extract(year from tre.start_date)	) one on to_char(one.school) = sch.school_code
	LEFT OUTER JOIN
	(SELECT
		tre.school_choice_2 as school,
	 	count(distinct tre.pupil_number) as students,
	 	extract(year from tre.start_date) as school_year
	FROM
		K12INTEL_STAGING.MPS_SAP_STUDENT_3CHOICE tre
	WHERE
		tre.school_choice_2 in ('116', '212', '270', '615', '194', '325', '312', '149', '42', '4', '399',  '664')
		and extract(year from tre.start_date)  in ('2013', '2014')
	GROUP BY
		tre.school_choice_2,
		extract(year from tre.start_date)	) two  on to_char(two.school) = sch.school_code
													and one.school_year = two.school_year
	LEFT OUTER JOIN
	(SELECT
		tre.school_choice_3 as school,
	 	count(distinct tre.pupil_number) as students,
	 	extract(year from tre.start_date) as school_year
	FROM
		K12INTEL_STAGING.MPS_SAP_STUDENT_3CHOICE tre
	WHERE
		tre.school_choice_3 in ('116', '212', '270', '615', '194', '325', '312', '149', '42', '4', '399',  '664')
		and extract(year from tre.start_date)  in ('2013', '2014')
	GROUP BY
		tre.school_choice_3,
		extract(year from tre.start_date)	) three on to_char(three.school) = sch.school_code
													  and three.school_year = two.school_year
													  and three.school_year = one.school_year
WHERE
	sch.school_code in ('116', '212', '270', '615', '194', '325', '312', '149', '42', '4', '399', '664')
ORDER BY
	sch.school_name,
	one.school_year
