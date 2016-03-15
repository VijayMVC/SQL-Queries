SELECT
--     Case when MPSD_Star_Targets.SEASON = 'Fall' then 
--                    case when Five_Percent_Line.Average_RIT - Five_Percent_Line.Target_RIT_Score < 0 
--                              then Five_Percent_Line.Average_RIT - Five_Percent_Line.Target_RIT_Score else null end 
--                    when MPSD_Star_Targets.SEASON = 'Winter' then 
--                    case when Five_Percent_Line.Average_RIT - Five_Percent_Line.Target_RIT_Score < 0 
--                              then (Five_Percent_Line.Average_RIT - Five_Percent_Line.Target_RIT_Score) * .975 else null end 
--                    when MPSD_Star_Targets.SEASON = 'Spring' then 
--                              case when Five_Percent_Line.Average_RIT - Five_Percent_Line.Target_RIT_Score < 0 
--                              then (Five_Percent_Line.Average_RIT - Five_Percent_Line.Target_RIT_Score) * .95 else null end 
--                              end AS "C9110"
    school.avg_percentile - mpsd_star_targets.target_percentile as gap
    ,mpsd_star_targets.Season||' '|| 
        case when MPSD_star_targets.Grade = 'K5' then 'K5' 
          when MPSD_star_targets.Grade = '01' then '1st' 
          when MPSD_star_targets.Grade = '02' then '2nd' 
          when MPSD_star_targets.Grade = '03' then '3rd' 
          when MPSD_star_targets.Grade in ('04','05','06','07','08','09') then substr(MPSD_star_targets.Grade,2,1)||'th' 
          when MPSD_star_targets.Grade in ('10','11') then MPSD_star_targets.Grade||'th' else MPSD_star_targets.Grade end as grade 
    ,mpsd_star_targets.school_year
--    ,case when mpsd_star_targets.season = 'Fall' then target.fall_target 
--      when mpsd_star_targets.season = 'Winter' then target.winter_target
--      when mpsd_star_targets.season = 'Spring' then target.spring_target end as target
FROM
    K12INTEL_DW.MPSD_STAR_TARGETS
    LEFT JOIN
        (SELECT sc.season, sc.school_year, sc.grade, sc.subject, avg(sc.test_percentile_score) as avg_percentile
        FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES sc
            INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on sc.student_annual_attribs_key = dtbl_student_annual_attribs.student_annual_attribs_key
        WHERE 1=1
           and sc.school_key = 430 --WITH ALL PROMPTS
        GROUP BY sc.season, sc.school_year, sc.grade, sc.subject
         ) school on school.season = mpsd_star_targets.season
                and SChool.GRADE = mpsd_star_targets.grade
                and school.school_year = mpsd_star_targets.school_year
                and school.subject = mpsd_star_targets.subject
     INNER JOIN
         (SELECT sc.school_year, sc.grade, sc.subject
                ,case when avg(sc.test_percentile_score) >= avg(sc.target_percentile) then null else
                  avg(sc.test_percentile_score) - avg(sc.target_percentile) end as fall_target
                ,case when avg(sc.test_percentile_score) >= avg(sc.target_percentile) then null else
                ((avg(sc.target_percentile) - avg(sc.test_percentile_score)) * .05) + (avg(sc.test_percentile_score) - avg(sc.target_percentile)) end as winter_target
                ,case when avg(sc.test_percentile_score) >= avg(sc.target_percentile) then null else
                ((avg(sc.target_percentile) - avg(sc.test_percentile_score)) * .1) + (avg(sc.test_percentile_score) - avg(sc.target_percentile)) end as spring_target
        FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES sc
            INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on sc.student_annual_attribs_key = dtbl_student_annual_attribs.student_annual_attribs_key
        WHERE 1=1
           and sc.school_key = 430
           and sc.season = 'Fall' --WITH ALL PROMPTS
        GROUP BY sc.school_year, sc.grade, sc.subject
         ) target on target.GRADE = mpsd_star_targets.grade
                and target.school_year = mpsd_star_targets.school_year
                and target.subject = mpsd_star_targets.subject       
   INNER JOIN 
        (SELECT distinct grade
        FROM  K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES sc
        WHERE sc.school_key = 430 --SCHOOL FILTER
        ) gr on gr.grade = mpsd_star_targets.grade          
--ORDER BY
--    2,3,4 
;
select school_Key from k12intel_dw.dtbl_schools where school_name like 'HAMILTON%'