SELECT
	ACT_scores.collection_year,
	ACT_scores.test_subject,
	ACT_scores.student_id,
	ACT_scores.score,
	case when ACT_scores.test_subject = 'English' and ACT_scores.score >= 18 then 1
		when  ACT_scores.test_subject = 'Reading' and ACT_scores.score >= 22 then 1
		when ACT_scores.test_subject = 'Mathematics' and ACT_scores.score >= 22 then 1
		when ACT_scores.test_subject = 'Science' and ACT_scores.score >= 23 then 1
		when ACT_scores.test_subject = 'Composite' then null else 0 end as college_ready
FROM
	(SELECT
	  tf.collection_year,
	  tf.STUDENT_id,
	  tst.test_subject,
	--  sd.date_value,
	max( tscr.test_scaled_score) as score
	FROM
	  K12INTEL_DW.MPSD_STATE_AIDS tf
	  LEFT OUTER JOIN
	   (K12INTEL_DW.FTBL_TEST_SCORES tscr
	   		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
	   		INNER JOIN K12INTEL_DW.DTBL_TESTS tst on (tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT' and
	   			tst.test_class = 'COMPONENT' AND tst.test_subject in ('English', 'Reading', 'Mathematics', 'Science', 'Composite')     ) )
	   on tf.student_key = tscr.student_key and sd.date_value <= tf.collection_date
	WHERE
	 (	TF.STUDENT_GRADE_CODE  =  '12' and
	   TF.COLLECTION_TYPE = 'PRODUCTION' AND
	   tf.school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE')  and
	   TF.STUDENT_COUNTABLE_INDICATOR = 'Yes'  AND
	   TF.COLLECTION_YEAR  in ('2009-2010', '2010-2011', '2011-2012',  '2012-2013', '2013-2014') AND
	   TF.COLLECTION_PERIOD  =  'May 3rd Friday')
	group by
		 tf.STUDENT_id,
		   tst.test_subject,
		   tf.collection_year ) ACT_scores
