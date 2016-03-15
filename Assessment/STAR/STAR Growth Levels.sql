SELECT
    subject
    ,school_year
    ,base_result
    ,compared_result
    ,students
    ,sum(students) over (partition by subject, school_year) as total
--     case when base_result.result = 'Blue' and compared_to.result in ('Green','Yellow', 'Orange','Red') then ' font-weight: 700; background-color: #FA8072;'
--                      when base_result.result = 'Green' and compared_to.result in ('Yellow', 'Orange','Red') then 'font-weight: 700; background-color: #FA8072;'
--                      when base_result.result = 'Yellow' and compared_to.result in ('Orange','Red') then 'font-weight: 700; background-color: #FA8072;'
--                      when base_result.result = 'Orange' and compared_to.result = 'Red' then 'font-weight: 700; background-color: #FA8072;'
--                      when base_result.result = 'Red' and compared_to.result in ('Green','Yellow', 'Orange','Blue') then 'font-weight: 700; background-color: #ADFF2F;'
--                      when base_result.result = 'Orange' and compared_to.result in ('Green','Yellow', 'Blue') then 'font-weight: 700; background-color: #ADFF2F;'
--                      when base_result.result = 'Yellow' and compared_to.result in ('Green','Blue') then 'font-weight: 700; background-color: #ADFF2F;'
--                      when base_result.result = 'Green' and compared_to.result in ('Blue') then 'font-weight: 700; background-color: #ADFF2F;' else 'font-weight: 700; background-color: #FFFFFF;'  end  AS "C2318"
--
FROM
    (
    SELECT
          base_result.subject,
          base_result.school_year,
          Base_Result.result AS base_result,
         Compared_To.result  AS compared_result,
         count(Base_Result.student_key)  AS students
    FROM
         ( 
              SELECT 
                  K12INTEL_DW.mps_mv_map_component_scores.student_key, 
                  K12INTEL_DW.mps_mv_map_component_scores.school_key,     subject, 
                  K12INTEL_DW.mps_mv_map_component_scores.student_annual_attribs_key,
                  K12INTEL_DW.mps_mv_map_component_scores.test_student_grade, 
                  K12INTEL_DW.mps_mv_map_component_scores.school_year, 
                  K12INTEL_DW.mps_mv_map_component_scores.test_admin_period, 
                  case when K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Significantly Above' then 'Blue' 
                           when  K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'On Target' then 'Green' 
                           when  K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Below Target' then 'Yellow' 
                           when  K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Well Below Target' then 'Orange' 
                           when K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Significantly Below Target' then 'Red' else 'Untested' end AS Result 
                  ,K12INTEL_DW.mps_mv_map_component_scores.TEST_PERCENTILE_SCORE 
                  ,K12INTEL_DW.mps_mv_map_component_scores.Test_scaled_score as RIT 
              FROM 
                  K12INTEL_DW.mps_mv_map_component_scores 
                  inner join k12intel_dw.dtbl_students on K12INTEL_DW.mps_mv_map_component_scores.student_key = dtbl_students.student_key 
              WHERE 
                  K12INTEL_DW.mps_mv_map_component_scores.test_student_grade<>'12' 
                  AND K12INTEL_DW.mps_mv_map_component_scores.test_primary_result <> 'Untested'
                  and mps_mv_map_component_scores.school_year = '2014-2015' --And @@PROMPT(Was In School Year,"mps_mv_map_component_scores.school_year",=,IN,"1<>1",string) 
                  and mps_mv_map_component_scores.test_admin_period = 'Fall'-- @@PROMPT(WasInSeason,"",=,PromptDefault,"1=1",direct)
                            )  Base_Result 
              inner join 
              ( 
              SELECT K12INTEL_DW.mps_mv_map_component_scores.student_key, 
                  K12INTEL_DW.mps_mv_map_component_scores.school_key,    subject, 
                  K12INTEL_DW.mps_mv_map_component_scores.school_year, 
                  K12INTEL_DW.mps_mv_map_component_scores.test_admin_period, 
                  case when K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Significantly Above' then 'Blue' 
                           when  K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'On Target' then 'Green' 
                           when  K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Below Target' then 'Yellow' 
                           when  K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Well Below Target' then 'Orange' 
                           when K12INTEL_DW.mps_mv_map_component_scores.test_primary_result = 'Significantly Below Target' then 'Red' else 'Untested' end AS Result 
                   ,mps_mv_map_component_scores.TEST_PERCENTILE_SCORE 
                   ,mps_mv_map_component_scores.Test_scaled_score as RIT 
              FROM 
                  K12INTEL_DW.mps_mv_map_component_scores 
                  inner join k12intel_dw.dtbl_students on K12INTEL_DW.mps_mv_map_component_scores.student_key = dtbl_students.student_key 
              WHERE 
                  K12INTEL_DW.mps_mv_map_component_scores.test_student_grade<>'12' 
                  AND K12INTEL_DW.mps_mv_map_component_scores.test_primary_result <> 'Untested'
                  and mps_mv_map_component_scores.school_year = '2014-2015' --And @@PROMPT(Compared To School Year,"mps_mv_map_component_scores.school_year",=,IN,"1<>1",string) 
                  and mps_mv_map_component_scores.test_admin_period = 'Spring' --  @@PROMPT(ComparedToSeason,"",=,PromptDefault,"1=1",direct)  
                  )  Compared_To 
                  on base_result.student_key = compared_to.student_key 
                  --and @@PROMPT(Testing School,"",IN:Direct,promptdefault,"1=1",exact) 
                  and base_result.subject = compared_to.subject 
              inner join k12intel_dw.dtbl_students 
                       on base_result.student_key = dtbl_students.student_key
      --        inner join k12intel_dw.dtbl_student_annual_attribs on dtbl_student_annual_attribs.student_key = base_result.student_annual_attribs_key
              inner join k12intel_dw.dtbl_schools
                       on dtbl_schools.school_key = dtbl_students.school_key
                      -- and base_result.school_key = dtbl_schools.school_key and compared_to.school_key = dtbl_schools.school_key  --this join determines population
    WHERE 1=1
--         (base_result.subject = 'Reading')
         and dtbl_students.school_key = 430
--         and @@PROMPT(School,"dtbl_students.school_key",IN,IN,"1=1",string) 
--          And @@PROMPT(Compared to School Year,"mps_mv_map_component_scores.school_year",=,IN,"1<>1",string) 
--          and mps_mv_map_component_scores.test_admin_period @@PROMPT(ComparedtoSeason,"",=,default,"1=1",direct) 
--          AND (@@PROMPT(StudentCohort,"coalesce(DTBL_STUDENT_COHORT_MEMBERS.COHORT_NAME,'-1')",IN,promptdefault,"1=1",string))
--          AND (@@PROMPT(Ethnicity,"DTBL_STUDENTS.STUDENT_RACE",IN,default,"1=1",string)) 
--          AND (@@PROMPT(Sped,"DTBL_STUDENTS.STUDENT_SPECIAL_ED_INDICATOR",IN,default,"1=1",string)) 
--          AND (@@PROMPT(FRL,"DTBL_STUDENTS.STUDENT_FOODSERVICE_INDICATOR",IN,default,"1=1",string)) 
--          AND (@@PROMPT(ELL,"DTBL_STUDENTS.STUDENT_ESL_INDICATOR",=,default,"1=1",string)) 
--          AND (@@PROMPT(Grade,"K12INTEL_DW.DTBL_STUDENTS.STUDENT_CURRENT_GRADE_CODE",IN,default,"1=1",string)) 
--          AND (@@PROMPT(Sex,"DTBL_STUDENTS.STUDENT_GENDER",IN,default,"1=1",string)) 
--               AND ( 
--                    @@PROMPT(School Cohort,"'*'",=,promptdefault,"1=1",string)   
--                    OR 
--                    EXISTS 
--                    ( 
--                        SELECT 1 
--                        FROM K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS 
--                        WHERE  @@PROMPT(School Cohort,"DTBL_SCHOOL_COHORT_MEMBERS.COHORT_NAME ",IN,promptdefault,"1=1",string) 
--                        AND DTBL_STUDENTS.SCHOOL_KEY = K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS.SCHOOL_KEY   
--                    )) 
--                    AND 
--                    ( 
--                    @@PROMPT(Programs,"'*'",=,promptdefault,"1=1",string)   
--                    OR 
--                    EXISTS 
--                    ( 
--                        SELECT 1 
--                        FROM K12INTEL_DW.DTBL_PROGRAMS 
--                    inner join k12intel_dw.ftbl_program_membership 
--                    on k12intel_dw.ftbl_program_membership.program_key = K12INTEL_DW.DTBL_PROGRAMS.program_key  and ftbl_program_membership.membership_status = 'Active' 
--                    inner join k12intel_dw.dtbl_school_dates bdsd 
--                    on k12intel_dw.ftbl_program_membership.begin_school_date_key = bdsd.school_dates_key 
--                              and bdsd.rolling_local_school_yr_number = 0 
--                    WHERE program_type = 'Programs' 
--                    and  @@PROMPT(Programs,"DTBL_PROGRAMS.PROGRAM_NAME ",IN,promptdefault,"1=1",string) 
--                    and K12INTEL_DW.DTBL_STUDENTS.STUDENT_KEY = k12intel_dw.ftbl_program_membership.student_key 
--                    )) 
    GROUP BY
          Base_Result.result,
         Compared_To.result ,
         base_result.subject,
          base_result.school_year 
    ORDER BY
         Base_Result.result,
         Compared_To.result
   )
     ;
     select * from K12INTEL_DW.mps_mv_map_component_scores
     
     
              case when base_result.result = 'Blue' and compared_to.result in ('Green','Yellow', 'Orange','Red') then ' font-weight: 700; background-color: #FA8072;'
                          when base_result.result = 'Green' and compared_to.result in ('Yellow', 'Orange','Red') then 'font-weight: 700; background-color: #FA8072;'
                          when base_result.result = 'Yellow' and compared_to.result in ('Orange','Red') then 'font-weight: 700; background-color: #FA8072;'
                          when base_result.result = 'Orange' and compared_to.result = 'Red' then 'font-weight: 700; background-color: #FA8072;'
                          when base_result.result = 'Red' and compared_to.result in ('Green','Yellow', 'Orange','Blue') then 'font-weight: 700; background-color: #ADFF2F;'
                          when base_result.result = 'Orange' and compared_to.result in ('Green','Yellow', 'Blue') then 'font-weight: 700; background-color: #ADFF2F;'
                          when base_result.result = 'Yellow' and compared_to.result in ('Green','Blue') then 'font-weight: 700; background-color: #ADFF2F;'
                          when base_result.result = 'Green' and compared_to.result in ('Blue') then 'font-weight: 700; background-color: #ADFF2F;' else 'font-weight: 700; background-color: #FFFFFF;'  end