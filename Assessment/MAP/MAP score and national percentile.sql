select
	st.student_id - 1234567 as scrambled_student_id,
	(case when trim(cd.month_name_short) in ('Aug','Sep','Oct','Nov') then 'Fall'
		when trim(cd.MONTH_NAME_SHORT) in ('Dec','Jan','Feb') then 'Winter'
		when trim(cd.MONTH_NAME_SHORT) in ('Mar','Apr','May','Jun') then 'Spring' else null end) as test_season,
	cd.date_value as test_date,
	tsc.test_student_grade,
	schaa.school_code,
	schaa.school_name,
	tst.test_type,
	tst.test_subject,
	tsc.test_scaled_score,
	tsc.test_percentile_score as national_percentile,
	case when tsc.test_percentile_score >= 75 then 'Significantly Above Target'
         when  fall_map.natl_pct between  trg_fall.target_percentile and 75 then 'On Target'
         when  fall_map.natl_pct >= 26 and fall_map.natl_pct < trg_fall.target_percentile then 'Below Target'
         when  fall_map.natl_pct between 11 and 25 then 'Well Below Target'
         when fall_map.natl_pct < 11 then 'Significantly Below Target' else 'Not Tested' end  Map_Performance_Group
from
	K12INTEL_DW.DTBL_STUDENTS st
	LEFT OUTER JOIN K12INTEL_DW.FTBL_TEST_SCORES tsc on tsc.student_key = st.student_key
	INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd  ON tsc.school_dates_key = sd.school_dates_key
	inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on tsc.school_annual_attribs_key = schaa.school_annual_attribs_key
	INNER JOIN k12intel_dw.MPSD_District_MAP_Targets map_trg on (case when
																		trim(cd.month_name_short) in ('Aug','Sep','Oct','Nov') then 'Fall'
																		when trim(cd.MONTH_NAME_SHORT) in ('Dec','Jan','Feb') then 'Winter'
																		when trim(cd.MONTH_NAME_SHORT) in ('Mar','Apr','May','Jun') then 'Spring'
																	else 'Summer' end = map_trg.SEASON  )
																	and map_trg.grade = tsc.test_student_grade
																	and map_trg.subject = tst.test_subject
																	and map_trg.school_year = sd.local_school_year
where
	(tst.TEST_TYPE  =  'MAP SCREENER'
	AND  tst.TEST_CLASS  =  'COMPONENT'  )
   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
   and sd.local_school_year in ('2012-2013', '2013-2014')
   and schaa.reporting_school_ind = 'Y'
ORDER BY 1,3


