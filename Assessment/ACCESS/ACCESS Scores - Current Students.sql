SELECT
	st.student_id,
	st.student_name,
	st.student_current_grade_code,
	sch.school_code as current_school_code,
	sch.school_name as current_school,
	sd.local_school_year as test_school_year,
	cd.date_value as test_date,                 -- Always Feb 1st of given school year
	tst.test_type,
	tst.test_subject ,
	tscr.test_student_grade as grade_when_tested,
	tscr.TEST_SCORE_VALUE as raw_score,
	tscr.test_scaled_score as scale_score ,
	tsx.TEST_EXT_DPI_LPI as ell_level
FROM
	K12INTEL_DW.FTBL_TEST_SCORES tscr
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on tscr.STUDENT_KEY=st.STUDENT_KEY
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_code = st.student_current_school_code
	INNER JOIN K12INTEL_DW.FTBL_TEST_SCORES_EXTENSION_3 tsx ON tscr.TEST_SCORES_KEY = tsx.TEST_SCORES_KEY
	INNER JOIN k12intel_dw.dtbl_school_dates sd ON TSCR.school_dates_key = sd.school_dates_key
	INNER JOIN k12intel_dw.dtbl_tests tst on tscr.tests_key = tst.tests_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates cD ON tscr.calendar_date_key = cd.calendar_date_key
WHERE
--	sd.local_school_year in ('2009-2010', '2011-2012', '2012-2013', '2013-2014')
	tst.test_class = 'COMPONENT'
	and tst.test_type like 'ACCESS%'
	and sch.school_code = '678'
	and sd.local_school_year = '2013-2014'
--	and tst.test_subject = 'DPI Language Proficiency'  --official subject for ELL level
--	and sch.school_code = '29'
ORDER BY
	st.student_id,
	sd.local_school_year,
	tst.test_type,
	tst.test_subject
;
