SELECT
     st.student_id,
     st.student_name,
     st.student_current_school,
     STUDENT_CURRENT_GRADE_CODE,
     st.student_gender,
     st.student_race_code,
     st.STUDENT_SPECIAL_ED_INDICATOR as SwD,
     case when st.STUDENT_ESL_CLASSIFICATION in ('Not Applicable', '7') then 'NA' else substr(st.STUDENT_ESL_CLASSIFICATION,1,1) end as LAU_Level,
     st.STUDENT_FOODSERVICE_INDICATOR AS Econ_Disadv,
     reading.test_percentile_score as reading_percentile_rank,
     reading.test_primary_result as reading_level,
     math.test_percentile_score as math_percentile_rank,
     math.test_primary_result as math_level     
FROM
      K12INTEL_DW.DTBL_STUDENTS st
       INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on st.school_key = sch.school_key 
       LEFT JOIN (SELECT * FROM
              (SELECT sc.*, row_number() over (Partition by sc.student_key, sc.subject ORDER BY date_value desc, test_primary_result_code desc, test_items_attempted desc) r
              FROM k12intel_dw.mps_mv_star_component_scores sc
              WHERE  sc.school_year='2015-2016'
              and subject = 'Reading'
              )
              WHERE r = 1
              ) reading
                  on reading.student_key = st.student_key
       LEFT JOIN (SELECT * FROM
              (SELECT sc.*, row_number() over (Partition by sc.student_key, sc.subject ORDER BY date_value desc, test_primary_result_code desc, test_items_attempted desc) r
              FROM k12intel_dw.mps_mv_star_component_scores sc
              WHERE  sc.school_year='2015-2016'
              and subject = 'Mathematics'
              )
              WHERE r = 1
              ) math
                  on math.student_key = st.student_key
WHERE
    st.student_current_grade_code = '02'
    and st.student_status = 'Enrolled' and st.student_activity_indicator = 'Active'
    and sch.school_code in (  '76' --alba
                              ,'316' --aal
                              ,'73' --allen
                              ,'295' --zab
                              ,'122' --curt
                              ,'173' --forest
                              ,'250' --linc
                              ,'387' --vict
                              ,'398' --whit
                              ,'232' --kagel
                              ) 
ORDER BY 3,2