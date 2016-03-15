SELECT
    ren.school_code
    ,ren.school_name
    ,ren.subject
    ,ren.grade
    ,map.gap as map_gap
    ,map.pct_of_target_reached as map_pct_target_reached
    ,ren.gap as ren_gap
    ,ren.pct_of_target_reached as ren_pct_target_reached
    ,map.pct_on_target as map_pct_on_abv_target  
    ,map.pct_sig_abv_target as map_abv
    ,map.pct_on_target as map_on
    ,map.pct_blw_target as map_blw
    ,map.pct_well_blw_target as map_well_blw
    ,map.pct_sig_blw_target as map_sig_blw
    ,ren.pct_on_target as ren_pct_on_abv_target
    ,ren.pct_sig_abv_target as ren_abv
    ,ren.pct_on_target as ren_on
    ,ren.pct_blw_target as ren_blw
    ,ren.pct_well_blw_target as ren_well_blw
    ,ren.pct_sig_blw_target as ren_sig_blw
    ,'55' as target_pct
FROM
    (SELECT
        sch.school_code
        ,sch.school_name
        ,map.school_year
        ,map.SEASON
        ,map.grade 
        ,map.subject
        ,round(avg(map.test_scaled_score),1) as avg_rit
        ,round(avg(map.TEST_SCALED_SCORE - trg.TARGET_RIT_SCORE),1) as gap
        ,round( avg(map.test_scaled_score) / trg.TARGET_RIT_SCORE,3) as pct_of_target_reached
    --    ,count(distinct st.student_key) as total_students
    --    ,count(distinct (case when map.test_primary_result_code in ('1','2') then st.student_key else null end)) as on_target
        ,round(count(distinct (case when map.test_primary_result_code in ('1','2') then st.student_key else null end))/count(distinct st.student_key),3) as pct_on_abv_target
        ,round(count(distinct (case when map.test_primary_result_code in ('1') then st.student_key else null end))/count(distinct st.student_key),3) as pct_sig_abv_target
        ,round(count(distinct (case when map.test_primary_result_code in ('2') then st.student_key else null end))/count(distinct st.student_key),3) as pct_on_target
        ,round(count(distinct (case when map.test_primary_result_code in ('3') then st.student_key else null end))/count(distinct st.student_key),3) as pct_blw_target
        ,round(count(distinct (case when map.test_primary_result_code in ('4') then st.student_key else null end))/count(distinct st.student_key),3) as pct_well_blw_target
        ,round(count(distinct (case when map.test_primary_result_code in ('5') then st.student_key else null end))/count(distinct st.student_key),3) as pct_sig_blw_target

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
        and map.test_primary_result_code != 6
    GROUP BY
        sch.school_code
        ,sch.school_name
        ,map.school_year
        ,map.SEASON
        ,map.grade 
        ,map.subject
        ,trg.target_rit_score
        ) map
    INNER JOIN
       ( SELECT
            sch.school_code
            ,sch.school_name
            ,str.school_year
            ,str.SEASON
            ,str.grade 
            ,str.subject
            ,trg.target_score
            ,trg.target_percentile
            ,round(avg(str.test_scaled_score),1) as avg_rit
            ,round(avg(str.TEST_SCALED_SCORE - trg.TARGET_SCORE),1) as gap
            ,round( avg(str.test_scaled_score) / trg.TARGET_SCORE,3) as pct_of_target_reached
        --    ,count(distinct st.student_key) as total_students
            ,count(distinct (case when str.test_scaled_score >= trg.target_score then st.student_key else null end)) as on_target
                    ,round(count(distinct (case when str.test_primary_result_code in ('1','2') then st.student_key else null end))/count(distinct st.student_key),3) as pct_on_abv_target
        ,round(count(distinct (case when str.test_percentile_score >= 75 then st.student_key else null end))/count(distinct st.student_key),3) as pct_sig_abv_target
        ,round(count(distinct (case when str.test_percentile_score between 55 and 74 then st.student_key else null end))/count(distinct st.student_key),3) as pct_on_target
        ,round(count(distinct (case when str.test_percentile_score between 26 and 54 then st.student_key else null end))/count(distinct st.student_key),3) as pct_blw_target
        ,round(count(distinct (case when str.test_percentile_score between 11 and 25  then st.student_key else null end))/count(distinct st.student_key),3) as pct_well_blw_target
        ,round(count(distinct (case when str.test_percentile_score between 0 and 10  then st.student_key else null end))/count(distinct st.student_key),3) as pct_sig_blw_target
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
        GROUP BY
            sch.school_code
            ,sch.school_name
            ,str.school_year
            ,str.SEASON
            ,str.grade 
            ,str.subject
            ,trg.target_score
            ,trg.target_percentile
           ) ren on ren.school_code = map.school_code
                 and ren.subject = map.subject
                 and ren.grade = map.grade
WHERE
    map.school_code in ('116', '212', '270', '615', '194', '325', '312', '149', '4', '42', '399')
ORDER BY
    ren.school_name
    ,ren.subject
    ,ren.grade