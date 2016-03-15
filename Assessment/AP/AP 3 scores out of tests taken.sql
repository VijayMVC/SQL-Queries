SELECT
  sd.local_school_year,
  sum(case when tscr.test_score_value >= 3 then 1 else 0 end) as test_3above,
  count(tscr.test_scores_key) as tests_taken,
  round(sum(case when tscr.test_score_value >= 3 then 1 else 0 end) / count(tscr.test_scores_key), 3) as pct_3above
--  tst.test_subject,
--	tscr.test_score_value
FROM
   K12INTEL_DW.FTBL_TEST_SCORES tscr
   INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
   INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key
WHERE
	TST.TEST_TYPE  =  'AP TEST'
	and tst.test_class = 'COMPONENT'
group by
	 sd.local_school_year
--	 tst.test_subject
order by
	1
