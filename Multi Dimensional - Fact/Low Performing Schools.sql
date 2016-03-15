SELECT
	sch.school_key
	,sch.school_code
	,case when ge.school_key is not null then 'GE'
		when com.school_key is not null then 'Commitment'
		else null end as ge_commitment
	,schx.school_state_id
    ,attd.attendance_rate
    ,abs.absentee_rate
    ,susp.susp_rate
    ,map_read.gap_closure
    ,map_read.pct_closure
    ,map_math.gap_closure
    ,map_math.pct_closure
FROM
    K12INTEL_DW.DTBL_SCHOOLS sch
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx  on schx.school_key = sch.school_key
    LEFT OUTER JOIN K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS ge on ge.school_key = sch.school_Key and ge.cohort_name like 'GE%'
    LEFT OUTER JOIN K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS com on com.school_key = sch.school_Key and com.cohort_name like 'Comm%'
    INNER JOIN
    	( select
			a.school_key,
   			round(sum(a.attendance_value)/sum(a.attendance_days), 3) as attendance_rate
		 from
		  	K12INTEL_DW.FTBL_ATTENDANCE_STUMONABSSUM  a
		 WHERE
		 	a.local_school_year = '2014-2015'
		 group by
	 	    a.school_key) attd on attd.school_key = sch.school_key
	LEFT OUTER JOIN
		(SELECT
			total_served.school_key,
			round(total_suspended.students_suspended/total_served.students_served, 3) as susp_rate
		FROM
				(SELECT
					count (distinct e.student_key) as students_served,
					e.school_key
				FROM
					K12INTEL_DW.FTBL_ENROLLMENTS e
				  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON e.school_dates_key_begin_enroll = adm_sd.school_dates_key
				  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
				  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
				WHERE
					(e.ENROLLMENT_TYPE  =  'Actual'
					and reg_sd.LOCAL_SCHOOL_YEAR in ('2014-2015' )
					and e.enrollment_days > 2
					and extract(month from adm_sd.date_value) <> 7)
				GROUP BY
					e.school_key
				 ) total_served
			LEFT OUTER JOIN
				(SELECT
				  count (distinct da.student_key) as students_suspended,
				  da.school_key
				FROM
				  K12INTEL_DW.FTBL_DISCIPLINE d
				  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
				  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
				WHERE
					actd.local_school_year in ('2014-2015'  )
					and da.DISCIPLINE_ACTION_TYPE_CODE IN ('OS', 'OSS', '33', '37')
				GROUP BY
					da.school_key
									) total_suspended
									ON total_served.school_key = total_suspended.school_key
			) susp  on susp.school_key = sch.school_key
    LEFT OUTER JOIN
		(SELECT
			   	ab.school_key,
			   	count(distinct case when ab.absentee = 'Yes' then ab.student_key else null end) as absentee_students,
				round (count(distinct case when ab.absentee = 'Yes' then ab.student_key else null end) / count (distinct ab.student_key) , 3)  absentee_rate
		FROM
			(SELECT
				  sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
				  a.school_key,
				  a.student_key,
				  sum(a.attendance_days)  as total_membership_days,
				  sum(a.attendance_days - a.attendance_value)  as total_absence_days,
				  sum(case when a.excused_absence = 'Excused Absence' then a.attendance_days - a.attendance_value else 0 end) as excused_absence_days,
				  sum(case when a.excused_absence = 'Un-Excused Absence' or a.excused_absence = 'Unexcused Absence'  then
				  				case when a.excused_authorized = 'Yes' then 0 else a.attendance_days - a.attendance_value end
				  			else 0 end) as unexcused_absence_days,
				  round( (sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100, 2) as attendance_percentage,
				  case when ((sum(a.attendance_value)   /   sum(a.attendance_days) )  * 100) <= 84 then 'Yes' else 'No' end as absentee
			  FROM
			  		k12intel_dw.ftbl_attendance_stumonabssum a,
			       k12intel_dw.dtbl_calendar_dates c,
			       k12intel_dw.dtbl_schools s,
			       k12intel_dw.dtbl_schools_extension sx,
			       k12intel_dw.dtbl_students st,
			       k12intel_dw.dtbl_students_evolved se,
			       K12INTEL_DW.DTBL_SCHOOL_DATES sd
			 WHERE
			       a.calendar_date_key  = c.calendar_date_key
			       and a.school_dates_key = sd.school_dates_key
			       AND a.school_key = s.school_key
			       AND a.student_key = st.student_key
			       and se.student_evolve_key  = a.student_evolve_key
			       and  s.school_key = sx.school_key
			       and sx.group1 in ('01', '02', '03', '04', '05', '06', '07', '08')
			       and se.student_current_grade_code not in ('HS', 'K3', 'K4')  -- only use for accountability
			       and (sd.local_school_year in ('2014-2015' ) )         -- *** enter each school year to export seperately
			GROUP BY
			  		sd.LOCAL_SCHOOL_YEAR,
			 		a.student_key,
			 		a.school_Key
			having sum(a.attendance_days) >= 45) ab   --commment this out because not for accountability, for action
	GROUP BY
		ab.school_key ) abs on abs.school_key = sch.school_key
	LEFT OUTER JOIN
		(SELECT
			school_key,
		     case when Fall >= 0 and Spring >= 0 then 'No Gap' else cast (round(Spring - Fall,1) as varchar(6)) end AS Gap_Closure,
		     case when Spring >= 0 and Fall >= 0 then 'No Gap'
		                when Fall = 0 and Spring < 0 then round((Spring-Fall) * -100,1)||'%'
		                when Fall > 0 and Spring < 0 then round (((Spring-Fall)/Fall) * -100,1)||'%'
		                 else  round(((Spring-Fall)/Fall) * 100,1)||'%' end AS Pct_Closure
		FROM
		     (SELECT
		           map.school_key,
		           round(avg(map.TEST_SCALED_SCORE - map.TARGET_RIT_SCORE),1)  Average_Gap,
		           map.SEASON,
		           map.subject,
		           map.school_year
		     FROM
		          K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES map
		     WHERE
					map.TEST_STUDENT_GRADE  IN  ( 'K5','01','02','03','04','05','06','07','08','09','10','11'  )
					and   map.TEST_SCALED_SCORE  >  0
					and (map.subject IN ('Reading')
					and map.SCHOOL_YEAR IN ('2014-2015'))
			GROUP BY
		           map.school_key,
		           map.season,
		           map.subject,
		           map.school_year  ) gap
		 	pivot
		               (max(average_gap)
		                 for Season in ('Fall' as Fall,'Winter' as Winter,'Spring' as Spring))
		 	 ) map_read on map_read.school_key = sch.school_key
	LEFT OUTER JOIN
		(SELECT
			school_key,
		     case when Fall >= 0 and Spring >= 0 then 'No Gap' else cast (round(Spring - Fall,1) as varchar(6)) end AS Gap_Closure,
		     case when Spring >= 0 and Fall >= 0 then 'No Gap'
		                when Fall = 0 and Spring < 0 then round((Spring-Fall) * -100,1)||'%'
		                when Fall > 0 and Spring < 0 then round (((Spring-Fall)/Fall) * -100,1)||'%'
		                 else  round(((Spring-Fall)/Fall) * 100,1)||'%' end AS Pct_Closure
		FROM
		     (SELECT
		           map.school_key,
		           round(avg(map.TEST_SCALED_SCORE - map.TARGET_RIT_SCORE),1)  Average_Gap,
		           map.SEASON,
		           map.subject,
		           map.school_year
		     FROM
		          K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES map
		     WHERE
					map.TEST_STUDENT_GRADE  IN  ( 'K5','01','02','03','04','05','06','07','08','09','10','11'  )
					and   map.TEST_SCALED_SCORE  >  0
					and (map.subject IN ('Mathematics')
					and map.SCHOOL_YEAR IN ('2014-2015'))
			GROUP BY
		           map.school_key,
		           map.season,
		           map.subject,
		           map.school_year  ) gap
		 	pivot
		               (max(average_gap)
		                 for Season in ('Fall' as Fall,'Winter' as Winter,'Spring' as Spring))
		 	 ) map_math on map_math.school_key = sch.school_key
WHERE 1=1
	and sch.reporting_school_ind = 'Y'
--	and to_number(schx.school_state_id) in
--		(6,
--		12,
--		14,
--		16,
--		18,
--		20,
--		26,
--		27,
--		29,
--		32,
--		33,
--		38,
--		41,
--		52,
--		59,
--		71,
--		73,
--		75,
--		77,
--		81,
--		89,
--		92,
--		93,
--		94,
--		95,
--		98,
--		103,
--		104,
--		107,
--		108,
--		109,
--		110,
--		111,
--		113,
--		114,
--		116,
--		117,
--		118,
--		122,
--		125,
--		130,
--		140,
--		143,
--		145,
--		146,
--		148,
--		150,
--		152,
--		154,
--		155,
--		158,
--		162,
--		165,
--		167,
--		170,
--		173,
--		176,
--		177,
--		178,
--		179,
--		182,
--		185,
--		188,
--		191,
--		192,
--		193,
--		194,
--		196,
--		199,
--		202,
--		203,
--		204,
--		205,
--		208,
--		209,
--		210,
--		211,
--		212,
--		214,
--		217,
--		218,
--		223,
--		226,
--		232,
--		235,
--		236,
--		237,
--		238,
--		241,
--		250,
--		253,
--		256,
--		257,
--		265,
--		267,
--		268,
--		274,
--		277,
--		282,
--		283,
--		289,
--		295,
--		296,
--		301,
--		307,
--		312,
--		313,
--		315,
--		316,
--		319,
--		325,
--		334,
--		337,
--		343,
--		344,
--		350,
--		356,
--		360,
--		362,
--		365,
--		368,
--		377,
--		387,
--		390,
--		397,
--		398,
--		399,
--		407,
--		409,
--		410,
--		412,
--		413,
--		416,
--		419,
--		424,
--		432,
--		433,
--		434,
--		435,
--		441,
--		443,
--		444,
--		446,
--		447,
--		458,
--		501,
--		525,
--		805,
--		820,
--		825,
--		852,
--		865,
--		870,
--		875,
--		880,
--		1063,
--		1072,
--		1074,
--		1078,
--		1086,
--		1121)
