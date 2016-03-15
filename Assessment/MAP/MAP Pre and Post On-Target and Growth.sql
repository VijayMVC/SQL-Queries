SELECT
	'2012-2013' as year,
	pre_post.student_id,
	pre_post.school_code,
	pre_post.test_subject,
	pre_post.pre_season,
	pre_post.pre_grade,
	pre_post.pre_rit,
	pre_post.post_season,
	pre_post.post_grade,
	pre_post.post_rit,
	pre_post.post_rit - pre_post.pre_rit as RIT_growth,
	pre_post.post_natl_pct,
	case when pre_post.post_natl_pct >= 76 then 1
                                     when  pre_post.post_natl_pct between  map_trg.target_percentile and 75 then 2
                                     when  pre_post.post_natl_pct >= 26 and pre_post.post_natl_pct< map_trg.target_percentile then 3
                                     when  pre_post.post_natl_pct between 11 and 25 then 4
                                     when pre_post.post_natl_pct < 11 then 5 else 6 end  Performance_Sort,
                         case when pre_post.post_natl_pct >= 76 then 'Significantly Above Target'
                                     when  pre_post.post_natl_pct between  map_trg.target_percentile and 75 then 'On Target'
                                     when  pre_post.post_natl_pct >= 26 and pre_post.post_natl_pct < map_trg.target_percentile then 'Below Target'
                                     when  pre_post.post_natl_pct between 11 and 25 then 'Well Below Target'
                                     when pre_post.post_natl_pct < 11 then 'Significantly Below Target' else 'NA' end  Performance_Group
FROM
(SELECT
	st.student_id,
	sch.school_code,
	stu_list.test_subject,
	case when fall_map.rit is not null then fall_map.season else win_map.season end as pre_season,
	case when fall_map.rit is not null then fall_map.test_student_grade else win_map.test_student_grade end as pre_grade,
	case when fall_map.rit is not null then fall_map.rit else win_map.rit end as pre_rit,
	case when spr_map.rit is null then win_map.season else spr_map.season end as post_season,
	case when spr_map.rit is null then win_map.test_student_grade else spr_map.test_student_grade end as post_grade,
	case when spr_map.rit is null then win_map.rit else spr_map.rit end as post_rit,
	case when spr_map.rit is null then win_map.natl_pct else spr_map.natl_pct end as post_natl_pct,
	case when spr_map.rit is null then trg_win.target_rit_score else trg_spr.target_rit_score end as post_target_rit
FROM
	(select distinct
		tsc.student_key,
		tsc.school_key,
		tst.test_subject
	FROM
		K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
		INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
		inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on tsc.school_dates_key = sd.school_dates_key
	where
		(tst.TEST_TYPE  =  'MAP SCREENER'
		AND  tst.TEST_CLASS  =  'COMPONENT'  )
	   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
	      and sd.local_school_year = '2012-2013' ) stu_list
	LEFT OUTER JOIN
	(select
		'Fall' as season,
		tsc.student_key,
		tsc.school_key,
		tst.test_subject,
		tsc.test_student_grade,
		tscx.TEST_EXT_NATL_PERCENT_SCORE as natl_pct,
		tsc.test_scaled_score AS RIT
	from
		K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
		INNER JOIN k12intel_dw.ftbl_test_scores_extension tscx  on tsc.test_scores_key = tscx.test_scores_key
		INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
		inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
	where
		(tst.TEST_TYPE  =  'MAP SCREENER'
		AND  tst.TEST_CLASS  =  'COMPONENT'  )
	   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
	      and cd.date_value = to_date('10/10/2012', 'MM/DD/YYYY') ) fall_map  on fall_map.student_key = stu_list.student_key
	      																		and fall_map.school_key = stu_list.school_key
	      																		and fall_map.test_subject = stu_list.test_subject
	LEFT OUTER JOIN
	(select
		'Winter' as season,
		tsc.student_key,
		tsc.school_key,
		tst.test_subject,
		tsc.test_student_grade,
		tscx.TEST_EXT_NATL_PERCENT_SCORE as natl_pct,
		tsc.test_scaled_score AS RIT
	from
		K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
		INNER JOIN k12intel_dw.ftbl_test_scores_extension tscx  on tsc.test_scores_key = tscx.test_scores_key
		INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
		inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
	where
		(tst.TEST_TYPE  =  'MAP SCREENER'
		AND  tst.TEST_CLASS  =  'COMPONENT'  )
	   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
	   and cd.date_value = to_date('01/18/2013', 'MM/DD/YYYY') ) win_map on win_map.student_key = stu_list.student_key
	   																	and win_map.school_key = stu_list.school_key
	   																	and win_map.test_subject = stu_list.test_subject
	LEFT OUTER JOIN
	(select
		'Spring' as season,
		tsc.student_key,
		tsc.school_key,
		tst.test_subject,
		tsc.test_student_grade,
		tscx.TEST_EXT_NATL_PERCENT_SCORE as natl_pct,
		tsc.test_scaled_score AS RIT
	from
		K12INTEL_DW.FTBL_TEST_SCORES_3 tsc
		INNER JOIN k12intel_dw.ftbl_test_scores_extension tscx  on tsc.test_scores_key = tscx.test_scores_key
		INNER JOIN K12INTEL_DW.DTBL_TESTS_3 tst  on tsc.tests_key = tst.tests_key
		inner join K12INTEL_DW.DTBL_CALENDAR_DATES cd on tsc.calendar_date_key = cd.calendar_date_key
	where
		(tst.TEST_TYPE  =  'MAP SCREENER'
		AND  tst.TEST_CLASS  =  'COMPONENT'  )
	   AND tst.TEST_SUBJECT  IN  ( 'Reading','Mathematics'  )
	    and cd.date_value = to_date('05/10/2013', 'MM/DD/YYYY') ) spr_map   on spr_map.student_key = stu_list.student_key
	      																		and spr_map.school_key = stu_list.school_key
	      																		and spr_map.test_subject = stu_list.test_subject
	LEFT OUTER JOIN k12intel_dw.MPSD_District_MAP_Targets trg_spr   ON trg_spr.grade = spr_map.test_student_grade
																and trg_spr.subject=spr_map.test_subject
																and trg_spr.season = 'Spring'
																and trg_spr.school_year =  '2012-2013'
	LEFT OUTER JOIN k12intel_dw.MPSD_District_MAP_Targets trg_win  ON trg_win.grade = win_map.test_student_grade
																and trg_win.subject=win_map.test_subject
																and trg_win.season = 'Winter'
																and trg_win.school_year =  '2012-2013'
	LEFT OUTER JOIN k12intel_dw.MPSD_District_MAP_Targets trg_fall  ON trg_fall.grade = fall_map.test_student_grade
																and trg_fall.subject=fall_map.test_subject
																and trg_fall.season = 'Fall'
																and trg_fall.school_year =  '2012-2013'
	INNER JOIN k12intel_dw.dtbl_students st on stu_list.student_key = st.student_key
	INNER JOIN k12intel_dw.dtbl_SCHOOLS sch on sch.school_key = stu_list.school_key
WHERE
	sch.school_code in ('418','422','426','430','432','450','423','429',
						'475','405','440','421','427','446','490','462','497','435')
	and ((fall_map.rit is not null and win_map.rit is not null) or (win_map.rit is not null and spr_map.rit is not null))
	) pre_post
LEFT OUTER JOIN k12intel_dw.MPSD_District_MAP_Targets map_trg on map_trg.SUBJECT = pre_post.test_subject
																and  map_trg.GRADE = pre_post.post_grade
																and map_trg.season = pre_post.post_season
GROUP BY
	pre_post.student_id,
	pre_post.school_code,
	pre_post.post_natl_pct,
	pre_post.post_grade,
	pre_post.pre_grade,
	pre_post.test_subject,
	pre_post.post_season,
	pre_post.pre_season,
	pre_post.pre_rit,
	pre_post.post_rit,
	pre_post.post_target_rit,
	map_trg.target_percentile,
    	case when pre_post.post_natl_pct >= 76 then 1
                                     when  pre_post.post_natl_pct between  map_trg.target_percentile and 75 then 2
                                     when  pre_post.post_natl_pct >= 26 and pre_post.post_natl_pct< map_trg.target_percentile then 3
                                     when  pre_post.post_natl_pct between 11 and 25 then 4
                                     when pre_post.post_natl_pct < 11 then 5 else 6 end,
        case when pre_post.post_natl_pct >= 76 then 'Significantly Above Target'
                 when  pre_post.post_natl_pct between  map_trg.target_percentile and 75 then 'On Target'
                 when  pre_post.post_natl_pct >= 26 and pre_post.post_natl_pct < map_trg.target_percentile then 'Below Target'
                 when  pre_post.post_natl_pct between 11 and 25 then 'Well Below Target'
                 when pre_post.post_natl_pct < 11 then 'Significantly Below Target' else 'NA' end
ORDER BY 2.5
