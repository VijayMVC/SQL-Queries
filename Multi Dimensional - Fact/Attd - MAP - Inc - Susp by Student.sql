SELECT
 	st.student_id,
 	st.student_name,
	st.student_race as race,
	st.student_gender_code as gender,
	st.student_foodservice_indicator as frl,
	st.student_special_ed_indicator as sped,
	st.student_esl_indicator as ell,
 	st.student_activity_indiCator as current_activity_indicator,
 	st.student_status as current_enrollment_status,
 	ST.STUDENT_current_grade_code as current_grade,
 	st.student_current_school_code as current_school_code,
 	st.STUDENT_current_school as current_school_name,

	map_math_fall_2011.natl_pct as fall_2011_map_math_natl_pct,
	map_math_fall_2011.rit_score as fall_2011_map_math_rit_score,
	map_read_fall_2011.natl_pct as fall_2011_map_read_natl_pct,
	map_read_fall_2011.rit_score as fall_2011_map_read_rit_score,
	map_math_win_2012.natl_pct as winter_2012_map_math_natl_pct,
	map_math_win_2012.rit_score as winter_2012_map_math_rit_score,
	map_read_win_2012.natl_pct as winter_2012_map_read_natl_pct,
	map_read_win_2012.rit_score as winter_2012_map_read_rit_score,
	map_math_spring_2012.natl_pct as spring_2012_map_math_natl_pct,
	map_math_spring_2012.rit_score as spring_2012_map_math_rit_score,
	map_read_spring_2012.natl_pct as spring_2012_map_read_natl_pct,
	map_read_spring_2012.rit_score as spring_2012_map_read_rit_score,
	map_math_fall_2012.natl_pct as fall_2012_map_math_natl_pct,
	map_math_fall_2012.rit_score as fall_2012_map_math_rit_score,
	map_read_fall_2012.natl_pct as fall_2012_map_read_natl_pct,
	map_read_fall_2012.rit_score as fall_2012_map_read_rit_score,
	map_math_win_2013.natl_pct as winter_2013_map_math_natl_pct,
	map_math_win_2013.rit_score as winter_2013_map_math_rit_score,
	map_read_win_2013.natl_pct as winter_2013_map_read_natl_pct,
	map_read_win_2013.rit_score as winter_2013_map_read_rit_score,
	map_math_spring_2013.natl_pct as spring_2013_map_math_natl_pct,
	map_math_spring_2013.rit_score as spring_2013_map_math_rit_score,
	map_read_spring_2013.natl_pct as spring_2013_map_read_natl_pct,
	map_read_spring_2013.rit_score as spring_2013_map_read_rit_score,
	map_math_fall_2013.natl_pct as fall_2013_map_math_natl_pct,
	map_math_fall_2013.rit_score as fall_2013_map_math_rit_score,
	map_read_fall_2013.natl_pct as fall_2013_map_read_natl_pct,
	map_read_fall_2013.rit_score as fall_2013_map_read_rit_score,
	map_math_win_2014.natl_pct as winter_2014_map_math_natl_pct,
	map_math_win_2014.rit_score as winter_2014_map_math_rit_score,
	map_read_win_2014.natl_pct as winter_2014_map_read_natl_pct,
	map_read_win_2014.rit_score as winter_2014_map_read_rit_score,

 	attd_2011.membership_days as ytd_2011_membership_days,
	attd_2011.absence_days as ytd_2011_absence_days,
	attd_2011.attendance_percentage as ytd_2011_attd_pct,
 	attd_2012.membership_days as ytd_2012_membership_days,
	attd_2012.absence_days as ytd_2012_absence_days,
	attd_2012.attendance_percentage as ytd_2012_attd_pct,
 	attd_2013.membership_days as ytd_2013_membership_days,
	attd_2013.absence_days as ytd_2013_absence_days,
	attd_2013.attendance_percentage as ytd_2013_attd_pct,

	susp_2011.ytd_suspensions as ytd_2011_suspensions,
	susp_2012.ytd_suspensions as ytd_2012_suspensions,
	susp_2013.ytd_suspensions as ytd_2013_suspensions
FROM
	K12INTEL_DW.DTBL_STUDENTS st
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on st.student_key = stx.student_key
	LEFT OUTER JOIN
		( select
				st.student_id,
			 	sum(a.attend_days)  as membership_days,
			    sum(a.attend_days - a.attend_value)  as absence_days,
			    round( (sum(a.attend_value)   /   sum(a.attend_days) )  * 100, 2) as attendance_percentage
			 from
			  		K12INTEL_DW.MPS_MV_ATTEND_YTD_SCHSTU a,
			        k12intel_dw.dtbl_students st
			 WHERE
			       a.student_key = st.student_key and
			       a.local_school_year = '2011-2012'
			 group by
		 	st.student_id) attd_2011 on st.student_id = attd_2011.student_id
	LEFT OUTER JOIN
		( select
				st.student_id,
			 	sum(a.attend_days)  as membership_days,
			    sum(a.attend_days - a.attend_value)  as absence_days,
			    round( (sum(a.attend_value)   /   sum(a.attend_days) )  * 100, 2) as attendance_percentage
			 from
			  		K12INTEL_DW.MPS_MV_ATTEND_YTD_SCHSTU a,
			        k12intel_dw.dtbl_students st
			 WHERE
			       a.student_key = st.student_key and
			       a.local_school_year = '2012-2013'
			 group by
		 	st.student_id) attd_2012 on st.student_id = attd_2012.student_id
	LEFT OUTER JOIN
		 	( select
				st.student_id,
			 	sum(a.attend_days)  as membership_days,
			    sum(a.attend_days - a.attend_value)  as absence_days,
			    round( (sum(a.attend_value)   /   sum(a.attend_days) )  * 100, 2) as attendance_percentage
			 from
			  		K12INTEL_DW.MPS_MV_ATTEND_YTD_SCHSTU a,
			        k12intel_dw.dtbl_students st
			 WHERE
			       a.student_key = st.student_key and
			       a.local_school_year = '2013-2014'
			 group by
		 	st.student_id) attd_2013 on st.student_id = attd_2013.student_id
	LEFT OUTER JOIN
		 	( select
				st.student_id,
			 	sum (nbrsuspensions) as ytd_suspensions
			 from
			  		K12INTEL_DW.MPS_MV_SUSP_YTD_SCHSTU d,
			        k12intel_dw.dtbl_students st
			 WHERE
			       d.student_key = st.student_key and
			       d.local_school_year = '2011-2012'
			 group by
		 	st.student_id ) susp_2011 on st.student_id = susp_2011.student_id
	LEFT OUTER JOIN
		 	( select
				st.student_id,
			 	sum (nbrsuspensions) as ytd_suspensions
			 from
			  		K12INTEL_DW.MPS_MV_SUSP_YTD_SCHSTU d,
			        k12intel_dw.dtbl_students st
			 WHERE
			       d.student_key = st.student_key and
			       d.local_school_year = '2012-2013'
			 group by
		 	st.student_id ) susp_2012 on st.student_id = susp_2012.student_id
	LEFT OUTER JOIN
		 	( select
				st.student_id,
			 	sum (nbrsuspensions) as ytd_suspensions
			 from
			  		K12INTEL_DW.MPS_MV_SUSP_YTD_SCHSTU d,
			        k12intel_dw.dtbl_students st
			 WHERE
			       d.student_key = st.student_key and
			       d.local_school_year = '2013-2014'
			 group by
		 	st.student_id ) susp_2013 on st.student_id = susp_2013.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2011-2012'
	    	and    sd.date_value = to_date('10/14/2011','mm/dd/yyyy')
	    	 )  map_math_fall_2011 on st.student_id = map_math_fall_2011.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2011-2012'
	    	and    ( sd.date_value = to_date('10/14/2011','mm/dd/yyyy'))
	    	 )  map_read_fall_2011 on st.student_id = map_read_fall_2011.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2011-2012'
	    	and    ( sd.date_value = to_date('01/27/2012','mm/dd/yyyy'))
	    	 )  map_math_win_2012 on st.student_id = map_math_win_2012.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2011-2012'
	    	and    ( sd.date_value = to_date('01/27/2012','mm/dd/yyyy') )
	    	 )  map_read_win_2012 on st.student_id = map_read_win_2012.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2011-2012'
	    	and    ( sd.date_value in ( to_date('05/18/2013','mm/dd/yyyy') ) )
	    	 )  map_math_spring_2012 on st.student_id = map_math_spring_2012.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2011-2012'
	    	and    ( sd.date_value in ( to_date('05/18/2013','mm/dd/yyyy') ) )
	    	 )  map_read_spring_2012 on st.student_id = map_read_spring_2012.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2012-2013'
	    	and    sd.date_value = to_date('10/10/2012','mm/dd/yyyy')
	    	 )  map_math_fall_2012 on st.student_id = map_math_fall_2012.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2012-2013' )
	    	and    ( sd.date_value = to_date('10/10/2012','mm/dd/yyyy'))
	    	 )  map_read_fall_2012 on st.student_id = map_read_fall_2012.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2012-2013' )
	    	and    ( sd.date_value = to_date('01/18/2013','mm/dd/yyyy'))
	    	 )  map_math_win_2013 on st.student_id = map_math_win_2013.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2012-2013' )
	    	and    ( sd.date_value = to_date('01/18/2013','mm/dd/yyyy') )
	    	 )  map_read_win_2013 on st.student_id = map_read_win_2013.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2012-2013' )
	    	and    ( sd.date_value in ( to_date('05/10/2013','mm/dd/yyyy'), to_date('05/17/2013','mm/dd/yyyy') ) )
	    	 )  map_math_spring_2013 on st.student_id = map_math_spring_2013.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2012-2013' )
	    	and    ( sd.date_value in ( to_date('05/10/2013','mm/dd/yyyy'), to_date('05/17/2013','mm/dd/yyyy') ) )
	    	 )  map_read_spring_2013 on st.student_id = map_read_spring_2013.student_id
	LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2013-2014' )
	    	and    ( sd.date_value in (to_date('10/11/2013','mm/dd/yyyy'), to_date('11/01/2013','mm/dd/yyyy') ))
	    	 )  map_math_fall_2013 on st.student_id = map_math_fall_2013.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year = '2013-2014' )
	    	and    ( sd.date_value in (to_date('10/11/2013','mm/dd/yyyy'), to_date('11/01/2013','mm/dd/yyyy') ))
	    	 )  map_read_fall_2013 on st.student_id = map_read_fall_2013.student_id
	 LEFT OUTER JOIN
		( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Mathematics' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year= '2013-2014' )
	    	and    ( sd.date_value in (to_date('01/22/2014','mm/dd/yyyy')))
	    	 )  map_math_win_2014 on st.student_id = map_math_win_2014.student_id
	LEFT OUTER JOIN
	    	 ( SELECT
			st.student_id,
			f.test_percentile_score as natl_pct,
	 		f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    ( sd.local_school_year = '2013-2014' )
	    	and    ( sd.date_value in (to_date('01/22/2014','mm/dd/yyyy')))
	    	 )  map_read_win_2014 on st.student_id = map_read_win_2014.student_id
WHERE
	st.student_id in ('8514427')
