SELECT
  tf.collection_year,
  tf.STUDENT_id,
--  tst.test_subject,
max( tscr.test_score_value)
FROM
  K12INTEL_DW.MPSD_STATE_AIDS tf
  LEFT OUTER JOIN
   (K12INTEL_DW.FTBL_TEST_SCORES tscr
   		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key  and SD.DATE_VALUE <= '09-01-2013'
   		INNER JOIN K12INTEL_DW.DTBL_TESTS tst on (tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'AP TEST' and
   			tst.test_class = 'COMPONENT' ) )
   on tf.student_key = tscr.student_key
WHERE
 (	TF.STUDENT_GRADE_CODE  =  '12' and
   TF.COLLECTION_TYPE = 'PRODUCTION' AND
   tf.school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE')  and
   TF.STUDENT_COUNTABLE_INDICATOR = 'Yes'  AND
   TF.COLLECTION_YEAR  =  '2012-2013' AND
   TF.COLLECTION_PERIOD  =  'May 3rd Friday')
group by
	 tf.collection_year,
	 tf.STUDENT_id
--	 tst.test_subject
order by
	2
