-- this query gets all records and all scores per student

SELECT
	sd2.local_school_year as post_test_year,
	cd2.date_value as post_test_date,                 -- Always Feb 1st of given school year
	st.student_id,
	tst2.test_type,
	tst2.test_subject ,
	schaa.school_code as post_school_tested_at,
	schaa.school_name as post_school_name,
	tscr1.test_student_grade as pre_grade_when_tested,
	tscr2.test_student_grade as post_grade_when_tested,
	tsx1.TEST_EXT_DPI_LPI as pre_ell_level,
	tsx2.test_ext_dpi_lpi as post_ell_level,
	tsx2.test_ext_dpi_lpi - tsx1.TEST_EXT_DPI_LPI as ell_level_growth,
	case when tsx2.test_ext_dpi_lpi - tsx1.TEST_EXT_DPI_LPI > .4 then 'Yes' else 'No' end as met_standard
FROM
	K12INTEL_DW.FTBL_TEST_SCORES tscr1
	INNER JOIN K12INTEL_DW.FTBL_TEST_SCORES tscr2 on tscr1.student_key = tscr2.student_key
	INNER JOIN k12intel_dw.dtbl_school_dates sd1 ON TSCR1.school_dates_key = sd1.school_dates_key
	INNER JOIN k12intel_dw.dtbl_school_dates sd2 ON TSCR2.school_dates_key = sd2.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on tscr2.STUDENT_KEY=st.STUDENT_KEY
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_annual_attribs schaa on tscr2.SCHOOL_KEY=schaa.SCHOOL_KEY and schaa.school_year = sd2.local_school_year and schaa.reporting_school_ind = 'Y'
	INNER JOIN K12INTEL_DW.FTBL_TEST_SCORES_EXTENSION_3 tsx2 ON tscr2.TEST_SCORES_KEY = tsx2.TEST_SCORES_KEY
	INNER JOIN K12INTEL_DW.FTBL_TEST_SCORES_EXTENSION_3 tsx1 ON tscr1.TEST_SCORES_KEY = tsx1.TEST_SCORES_KEY
	INNER JOIN k12intel_dw.dtbl_tests tst2 on tscr2.tests_key = tst2.tests_key
	INNER JOIN k12intel_dw.dtbl_tests tst1 on tscr1.tests_key = tst1.tests_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates cD2 ON tscr2.calendar_date_key = cd2.calendar_date_key
	INNER JOIN k12intel_dw.dtbl_calendar_dates cD1 ON tscr1.calendar_date_key = cd1.calendar_date_key
WHERE
	sd2.local_school_year in ('2009-2010', '2010-2011', '2011-2012', '2012-2013', '2013-2014')
	and extract(year from cd1.date_value) = extract(year from cd2.date_value) - 1
--	and substr(sd2.local_school_year,1,4) = to_char(to_number(substr(replace(sd1.local_school_year, '@ERR', '0000'),1,4))+1)
	and (tst2.test_class = tst1.test_class and tst1.test_subject = tst2.test_subject)
	and tst2.test_class = 'COMPONENT'
	and tst2.test_type like 'ACCESS%'
	and tst2.test_subject = 'DPI Language Proficiency'  --official subject for ELL level
ORDER BY
	st.student_id,
	cd2.date_value,
	tst2.test_type,
	tst2.test_subject
;
