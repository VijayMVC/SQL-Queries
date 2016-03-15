select
	st.student_id,
	st.student_name,
	std.student_birthdate,
	st.student_gender,
	st.student_race,
	ste.student_foodservice_indicator as frl_status_at_test_time,
	ste.student_esl_indicator as ell_status_at_test_time,
	ste.student_esl_classification as ell_level_at_test_time,
	ste.student_special_ed_indicator as sped_status_at_test_time,
	ste.student_special_ed_class as sped_cat_at_test_time,
	ste.student_educational_except_typ as sped_type_at_test_time,
	(case when trim(cd.month_name_short) in ('Aug','Sep','Oct','Nov') then 'Fall'
		when trim(cd.MONTH_NAME_SHORT) in ('Dec','Jan','Feb') then 'Winter'
		when trim(cd.MONTH_NAME_SHORT) in ('Mar','Apr','May','Jun') then 'Spring' else null end) as test_season,
	(case when trim(cd.month_name_short) in ('Aug','Sep','Oct','Nov') then 1
		when trim(cd.MONTH_NAME_SHORT) in ('Dec','Jan','Feb') then 2
		when trim(cd.MONTH_NAME_SHORT) in ('Mar','Apr','May','Jun') then 3 else null end) as season_sort,
	schaa.school_code,
	schaa.school_name,
	tsc.test_student_grade,
	tst.test_type,
	tst.test_subject,
	tsc.test_scaled_score,
	tsc.test_percentile_score
from
	K12INTEL_DW.DTBL_STUDENTS st
	INNER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS std on st.student_key = std.student_key
	INNER JOIN K12INTEL_DW.FTBL_TEST_SCORES tsc on tsc.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on tsc.student_evolve_key = ste.student_evolve_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on tsc.school_annual_attribs_key = schaa.school_annual_attribs_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT schaax on tsc.school_annual_attribs_key = schaax.school_annual_attribs_key
	INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd  ON tsc.school_dates_key = sd.school_dates_key
	inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
where
	(tst.TEST_TYPE  =  'MAP SCREENER'
	AND  tst.TEST_CLASS  =  'COMPONENT'  )
   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
   and sd.local_school_year = '2013-2014'
   and schaa.school_code in ('350', '26', '312', '238', '102', '25', '97')
   and schaa.reporting_school_ind = 'Y'
ORDER BY 1,12,17
