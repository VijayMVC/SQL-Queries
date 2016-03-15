SELECT
	school_key,
--     Fall,
--     Winter,
--     Spring,
--     case when Fall >= 0 and Winter >= 0 then 'No Gap' else cast (round(Winter - Fall,1) as varchar(6)) end AS "C6954",
--     case when Winter >= 0 and Fall >= 0 then 'No Gap'
--               when Fall = 0 and Winter < 0 then round((Winter-Fall) * -100,1)||'%'
--               when Fall > 0 and Winter < 0 then round (((Winter-Fall)/Fall) * -100,1)||'%'
--                else  round(((Winter-Fall)/Fall) * 100,1)||'%' end  AS "C6956",
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
ORDER BY   1
