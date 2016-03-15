SELECT
--	count(enr.student_id) as total,
--	count(distinct case when tc.student_id is not null then enr.student_id else null end) as choice
	enr.student_id,
	tc.*
FROM
	(SELECT
	  st.student_key,
	  st.STUDENT_ID
	FROM
	  K12INTEL_DW.FTBL_ENROLLMENTS e
	  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste ON StE.STUDENT_EVOLVE_KEY=E.STUDENT_EVOLVE_KEY
	  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st ON ST.STUDENT_KEY=E.STUDENT_KEY
	  INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES  Regdate ON Regdate.CALENDAR_DATE_KEY=e.CAL_DATE_KEY_REGISTER
	  INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES  Wddate ON E.CAL_DATE_KEY_END_ENROLL=WDDATE.CALENDAR_DATE_KEY
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch ON E.SCHOOL_KEY=SCH.SCHOOL_KEY
--	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES SD ON sd.
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx ON SCH.SCHOOL_KEY=schx.SCHOOL_KEY
	WHERE
	   Regdate.DATE_VALUE  >=  '08-30-2015 00:00:00'
	   AND  (wddate.DATE_VALUE  >=  '09-01-2015 00:00:00'  or wddate.date_value is null)
	   AND  e.ENROLLMENT_TYPE  =  'Actual'
		and e.entry_grade_code = '09'
	   and sch.school_code in ('14') ) enr
LEFT OUTER JOIN
	(SELECT
		distinct
	 	tre.pupil_number as student_id,
	 	tre.school_choice_1,
	 	tre.school_choice_2,
	 	tre.school_choice_3
	FROM
		K12INTEL_STAGING.MPS_SAP_STUDENT_3CHOICE tre
	WHERE  1=1
--		(tre.school_choice_1 = '14'
--		or tre.school_choice_2 = '14'
--		or tre.school_choice_3 = '14')
		and extract(year from tre.start_date)  in ('2015') --, '2014')
		and tre.grade = '09')  tc on to_char(tc.student_id) = enr.student_id

