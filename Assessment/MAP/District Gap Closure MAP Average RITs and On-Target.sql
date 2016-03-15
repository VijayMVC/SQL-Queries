select
	on_target.local_school_year,
	on_target.test_student_grade,
	on_target.test_subject,
	on_target.fall_avg_rit,
	on_target.fall_target_rit,
	on_target.fall_gap,
	on_target.spr_avg_rit,
	on_target.spr_target_rit ,
	on_target.spr_gap,
	on_target.gap_reduction,
	case when on_target.gap_reduction <= -3 then 'Blue'
			when on_target.gap_reduction between -3 and -1 then 'Green'
			when on_target.gap_reduction between -1 and 0 then 'Gray'
			when on_target.gap_reduction between 0 and 3 then 'Yellow'
			when on_target.gap_reduction >= 3 then 'Red' else null end as gap_closure_rating,
	round(on_target.gap_reduction / on_target.fall_gap, 3) as pct_reduction,
	case when round(on_target.gap_reduction / on_target.fall_gap, 3) >= .05 then 'Yes' else 'No' end as met_gap_target
FROM
(select
--	spr_map.school_code,
	spr_map.local_school_year,
	spr_map.test_student_grade,
	spr_map.test_subject,
	fall_map.avg_rit as fall_avg_rit,
	trg_fall.target_rit_score as fall_target_rit,
	sum(fall_map.avg_rit - trg_fall.target_rit_score) as fall_gap,
	spr_map.avg_rit as spr_avg_rit,
	trg_spr.target_rit_score as spr_target_rit ,
	sum(spr_map.avg_rit - trg_spr.target_rit_score) as spr_gap,
	sum((fall_map.avg_rit - trg_fall.target_rit_score) - (spr_map.avg_rit - trg_spr.target_rit_score)) as gap_reduction
FROM
(select
--	schaa.school_code,
	sd.local_school_year,
	tst.test_subject,
	tsc.test_student_grade,
	round(AVG(tsc.test_scaled_score),1) AS AVG_rit
from
	K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on tsc.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd  ON tsc.school_dates_key = sd.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_key = tsc.school_key and schaa.school_year = sd.local_school_year
	inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
where
	(tst.TEST_TYPE  =  'MAP SCREENER'
	AND  tst.TEST_CLASS  =  'COMPONENT'  )
   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
   and tsc.test_student_grade <> '12'
   and sd.local_school_year in ('2010-2011', '2011-2012', '2012-2013' )
	and cd.MONTH_NAME_SHORT in ('Mar','Apr','May','Jun')
	and schaa.reporting_school_ind = 'Y'
group by
	sd.local_school_year,
--	schaa.school_code,
	tst.test_subject,
	tsc.test_student_grade ) spr_map
INNER JOIN
(select
	sd.local_school_year,
--	schaa.school_code,
	tst.test_subject,
	tsc.test_student_grade,
	round(AVG(tsc.test_scaled_score),1) AS AVG_rit
from

	K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st ON tsc.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd  ON tsc.school_dates_key = sd.school_dates_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_key = tsc.school_key and schaa.school_year = sd.local_school_year
	inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
where
	(tst.TEST_TYPE  =  'MAP SCREENER'
	AND  tst.TEST_CLASS  =  'COMPONENT'  )
   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
   and sd.local_school_year in ('2010-2011', '2011-2012', '2012-2013' )
	and cd.MONTH_NAME_SHORT in ('Sep','Oct','Nov')
	and schaa.reporting_school_ind = 'Y'
group by
	sd.local_school_year,
--	schaa.school_code,
	tst.test_subject,
	tsc.test_student_grade  ) fall_map on --  spr_map.school_code = fall_map.school_code
										spr_map.test_student_grade = fall_map.test_student_grade
										and spr_map.test_subject = fall_map.test_subject
										and spr_map.local_school_year = fall_map.local_school_year
INNER JOIN k12intel_dw.MPSD_District_MAP_Targets trg_spr   ON trg_spr.grade = spr_map.test_student_grade
															and trg_spr.subject=spr_map.test_subject
															and trg_spr.season = 'Spring'
															and trg_spr.school_year =  '2012-2013'
INNER JOIN k12intel_dw.MPSD_District_MAP_Targets trg_fall  ON trg_fall.grade = fall_map.test_student_grade
															and trg_fall.subject=fall_map.test_subject
															and trg_fall.season = 'Fall'
															and trg_fall.school_year =  '2012-2013'
GROUP BY
--	spr_map.school_code,
	spr_map.local_school_year,
	spr_map.test_student_grade,
	spr_map.test_subject,
	fall_map.avg_rit,
	trg_fall.target_rit_score,
	spr_map.avg_rit,
	trg_spr.target_rit_score      ) on_target
WHERE
	(on_target.spr_avg_rit is not null
	and on_target.fall_avg_rit is not null)
ORDER BY
	1,3,2
