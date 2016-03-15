SELECT
	saa.school_code,
	sd.local_school_year,
	tsc.test_admin_period,
	tst.test_subject,
	tsc.test_student_grade,
	count(case when tsc.test_primary_result_code in (1,2) then tsc.student_key else null end) as on_target ,
	count(tsc.student_key) as ett,
	round( count(case when tsc.test_primary_result_code in (1,2) then tsc.student_key else null end)/count(tsc.student_key),2) as on_target_pct,
	round (avg(tsc.test_scaled_score),1) as average_RIT
FROM
	K12INTEL_DW.FTBL_TEST_SCORES tsc
	INNER JOIN K12INTEL_DW.DTBL_TESTS tst  on tsc.tests_key = tst.tests_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on tsc.school_dates_key = sd.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = tsc.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_key = tsc.school_key
  														  and saa.school_year = '2014-2015'
WHERE
	(tst.TEST_TYPE  =  'MAP SCREENER'
	and tst.TEST_CLASS  =  'COMPONENT' )
	and tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
 	and sd.local_school_year in ( '2014-2015'  )
    and tsc.test_admin_period = 'Spring'
 	and saa.reporting_school_ind = 'Y'
GROUP BY
	saa.school_code,
--	saa.school_name,
	sd.local_school_year,
    tsc.test_admin_period,
	tst.test_subject,
	tsc.test_student_grade
having count(case when tsc.test_primary_result_code != 6 then tsc.student_key else null end) > 0
ORDER BY 2,3,5,6,7

