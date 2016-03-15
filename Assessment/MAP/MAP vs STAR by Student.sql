SELECT
    st.student_id
    ,st.student_name
    ,ren.school_code
    ,ren.school_name
    ,ren.subject
    ,ren.grade
    ,map.test_primary_result_code as map_result_code
    ,map.test_primary_result as map_result
    ,ren.test_primary_result_code as ren_result_code
--    ,ren.test_primary_result as ren_result
    ,map.test_scaled_score as map_rit
    ,map.target_rit_score
    ,map.pct_of_target_reached as map_pct_target_reached
    ,ren.test_scaled_score as ren_rit
    ,ren.target_score
    ,ren.pct_of_target_reached as ren_pct_target_reached
    ,'55' as target_pct
FROM
    (SELECT
        map.student_key
        ,sch.school_code
        ,sch.school_name
        ,map.school_year
        ,map.SEASON
        ,map.grade 
        ,map.subject
        ,map.test_primary_result_code
        ,map.test_primary_result
        ,map.test_scaled_score
        ,map.test_percentile_score
        ,round(map.test_scaled_score / trg.TARGET_RIT_SCORE,3) as pct_of_target_reached
        ,trg.target_rit_score
    FROM
        K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES map
        inner join k12intel_dw.mpsd_district_map_targets trg on trg.subject = map.subject 
                                                               and trg.grade = map.grade
                                                               and trg.season = map.season
                                                               and trg.school_year = map.school_year
        inner join k12intel_dw.dtbl_schools sch on sch.school_key = map.school_key
        inner join K12INTEL_DW.DTBL_STUDENTS st on map.STUDENT_KEY = st.STUDENT_KEY
        inner join K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on map.STUDENT_ANNUAL_ATTRIBS_KEY = staa.STUDENT_ANNUAL_ATTRIBS_KEY
    WHERE 1=1
        and map.SCHOOL_YEAR IN ('2014-2015')
        and map.season = 'Fall'
        ) map
    INNER JOIN
       ( SELECT
            str.student_key
            ,sch.school_code
            ,sch.school_name
            ,str.school_year
            ,str.SEASON
            ,str.grade 
            ,str.subject
            ,case when str.test_percentile_score >= 75 then '1'
                when str.test_percentile_score between 55 and 74 then '2'
                when str.test_percentile_score between 26 and 54 then '3'
                when str.test_percentile_score between 11 and 25 then '4'
                when str.test_percentile_score < 11 then '5' end as test_primary_result_code
--            ,str.test_primary_result
            ,str.test_scaled_score
            ,str.test_percentile_score
            ,round(str.test_scaled_score / trg.TARGET_SCORE,3) as pct_of_target_reached
            ,trg.target_score
        FROM
            K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES str
            inner join k12intel_dw.mpsd_star_targets_55 trg on trg.subject = str.subject 
                                                                   and trg.grade = str.grade
                                                                   and trg.season = str.season
                                                                   and trg.school_year = str.school_year
            inner join k12intel_dw.dtbl_schools sch on sch.school_key = str.school_key
            inner join K12INTEL_DW.DTBL_STUDENTS st on str.STUDENT_KEY = st.STUDENT_KEY
            inner join K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on str.STUDENT_ANNUAL_ATTRIBS_KEY = staa.STUDENT_ANNUAL_ATTRIBS_KEY
        WHERE 1=1
            and str.SCHOOL_YEAR IN ('2015-2016')
            and str.season = 'Fall'
            and str.test_record_type = 'BM'
           ) ren on ren.student_key = map.student_key
                 and ren.subject = map.subject
     INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = ren.student_key
WHERE
    ren.school_code in ('116', '212', '270', '615', '194', '325', '312', '149', '4', '42', '399')
ORDER BY
    ren.school_name
    ,ren.subject
    ,ren.grade