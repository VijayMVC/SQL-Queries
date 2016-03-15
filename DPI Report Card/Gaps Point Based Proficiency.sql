-- Raw Scores - for Report Card Total Score see query below
SELECT
	saa.SCHOOL_CODE,
	saa.school_name,
	sd.LOCAL_SCHOOL_YEAR,
	to_number(substr(sd.local_school_year,1,4)) as fall_year,
	st.student_race,
----	st.student_special_ed_indicator,
----	st.student_esl_indicator,
--	st.student_foodservice_indicator,
	tst.TEST_SUBJECT,
--	tsc.TEST_STUDENT_GRADE,
	sum (case when tsc.test_standardized_score = 1 then 1 else 0 end) as Minimal_count,
	sum (case when tsc.test_standardized_score = 2 then 1 else 0 end) as Basic_count,
	sum (case when tsc.test_standardized_score = 3 then 1 else 0 end) as Proficient_count,
	sum (case when tsc.test_standardized_score = 4 then 1 else 0 end) as Advanced_count,
	sum (case when tsc.test_standardized_score is null then 1 else 0 end) as Untested_count,
	count(DISTINCT st.STUDENT_KEY) as Total_Count,
	sum (case when tsc.test_standardized_score is null then 0
		when tsc.test_standardized_score = 1 then 0
		when tsc.test_standardized_score = 2 then .5
		when tsc.test_standardized_score = 3 then 1
		when tsc.test_standardized_score = 4 then 1.5 else 0 end) as Proficiency_Points,
	round (sum (case when tsc.test_standardized_score in (3,4) then 1 else 0 end)/ count(DISTINCT st.STUDENT_KEY), 3) as ETT_Proficency_rate,
	round (sum (case when tsc.test_standardized_score is null then 0
		when tsc.test_standardized_score = 1 then 0
		when tsc.test_standardized_score = 2 then .5
		when tsc.test_standardized_score = 3 then 1
		when tsc.test_standardized_score = 4 then 1.5 else 0 end)/ count(DISTINCT st.STUDENT_KEY), 3) as Point_Based_Proficiency
FROM
	K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on tsc.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on st.student_key = stx.student_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tsc.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on tsc.school_annual_attribs_key = saa.school_annual_attribs_key
	INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tsc.tests_key
WHERE
	tst.tEST_CLASS  IN  ( 'COMPONENT'  )
	AND tst.TEST_TYPE  IN  ( 'WKCE','WAA - LEP','WAA - SDIS')
	AND tst.TEST_SUBJECT  IN  ( 'Reading', 'Mathematics' )
	AND sd.LOCAL_SCHOOL_YEAR in ('2009-2010') --, '2010-2011','2011-2012', '2012-2013', '2013-2014')
	AND saa.reporting_school_ind = 'Y'
	and saa.school_code = '18'
	AND tsc.student_key in (SELECT sa.student_key
							FROM K12INTEL_DW.MPSD_STATE_AIDS sa
							WHERE
								sa.student_key = tsc.student_key
								and sa.collection_period = 'September 3rd Friday'
								and sa.collection_type = 'PRODUCTION'
								and sa.student_countable_indicator = 'Yes'
								and (to_number(substr(sa.collection_year,1,4)) + 1) = to_number(substr(sd.local_school_year,1,4))
								and sa.countable_school_code = saa.school_code)
GROUP BY
	saa.SCHOOL_CODE,
	saa.school_name,
	st.student_race,
--	st.student_special_ed_indicator,
--	st.student_esl_indicator,
--	st.student_foodservice_indicator,
	sd.LOCAL_SCHOOL_YEAR,
--	tsc.TEST_STUDENT_GRADE,
	tst.TEST_SUBJECT
ORDER BY 1,3,4
 ;
