SELECT
	act.school_code,
	act.school_year,
	act.test_subject,
	round(sum(act.tested)/sum(act.total_students),3) as participation_rate,
	sum(act.college_ready) as number_college_ready,
	rounD(sum(act.college_ready)/sum(act.total_students),3) as pct_college_ready
FROM
	(SELECT
		tf.collection_year as school_year,
		tf.countable_school_code as school_code,
		tf.student_id,
		tst.test_subject,
		max(tscr.test_scaled_score) as score,
		case when tst.test_subject = 'Science' and max(tscr.test_scaled_score) >= 24
				then  1
			when tst.test_subject = 'English' and max(tscr.test_scaled_score) >= 18
				then  1
			when tst.test_subject = 'Mathematics' and max(tscr.test_scaled_score) >= 22
				then  1
			when tst.test_subject = 'Reading' and max(tscr.test_scaled_score) >= 21
				then  1 else 0 end as college_ready,
		case when max(tscr.test_scaled_score) is not null
				then  1 else 0 end as tested,
		count (*) as total_students
	FROM
	  K12INTEL_DW.MPSD_STATE_AIDS tf
	  LEFT OUTER JOIN
	   (K12INTEL_DW.FTBL_TEST_SCORES tscr
	   		INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key -- and SD.DATE_VALUE <= '09-01-2013'
	   		INNER JOIN K12INTEL_DW.DTBL_TESTS tst on (tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT' AND
	   					TST.TEST_SUBJECT in ('Science', 'Reading', 'English', 'Mathematics', 'Composite')   )  )
	   on tf.student_key = tscr.student_key
	WHERE
	 (	TF.STUDENT_GRADE_CODE  =  '12' and
	   TF.COLLECTION_TYPE = 'PRODUCTION' AND
	   tf.school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE')  and
	   TF.STUDENT_COUNTABLE_INDICATOR = 'Yes'  AND
	   tf.countable_school_code = '18' and
	   TF.COLLECTION_YEAR  in ('2010-2011', '2011-2012',  '2012-2013', '2013-2014') AND
	   TF.COLLECTION_PERIOD  =  'May 3rd Friday')
	group by
		 tf.collection_year,
		 tf.student_id,
		 tst.test_subject,
		tf.countable_school_code
	ORDER BY 3,4   ) act
GROUP BY
	act.school_year,
	act.school_code,
	act.test_subject
ORDER BY
1,2,3
