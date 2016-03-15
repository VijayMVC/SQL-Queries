SELECT
    sch.school_code
    ,sch.school_name
    ,st.student_id
    ,st.student_name
--    ,str.school_year
    ,str.test_admin_period
    ,str.test_student_grade 
    ,tst.test_subject
    ,str.test_primary_result_code
    ,str.test_primary_result
    ,str.test_scaled_score
    ,str.test_percentile_score
    ,trg.target_score
    ,trg.target_percentile
    ,str.test_scaled_score -trg.target_score as gap
FROM
    K12INTEL_METADATA.TEMP_TEST_SCORES_STAR str
    INNER JOIN K12INTEL_METADATA.TEMP_TESTS_STAR tst on str.tests_key = tst.tests_key
    inner join k12intel_dw.mpsd_star_targets_55 trg on trg.subject = tst.test_subject 
                                                           and trg.grade = str.test_student_grade
                                                           and trg.season = str.test_admin_period
                                                           and trg.school_year = '2015-2016'
    inner join k12intel_dw.dtbl_schools sch on sch.school_key = str.school_key
    inner join K12INTEL_DW.DTBL_STUDENTS st on str.STUDENT_KEY = st.STUDENT_KEY
--    inner join K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on str.STUDENT_ANNUAL_ATTRIBS_KEY = staa.STUDENT_ANNUAL_ATTRIBS_KEY
WHERE 1=1
--    and str.SCHOOL_YEAR IN ('2015-2016')
    and str.test_admin_period = 'Fall'
--    and tst.test_subject = 'Reading'
--    and str.test_student_grade = '05'
    and str.test_record_type = 'BM'
    and sch.school_code = '116'
ORDER BY
    2,7,6,4
    
;
 select * from k12intel_dw.dtbl_students where student_id = '8742145'
 ;
 select * from k12intel_metadata.temp_test_scores_star where student_key = '295503'