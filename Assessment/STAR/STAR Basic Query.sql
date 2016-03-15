SELECT
    tsc.test_scores_key
    ,tst.tests_key
    ,sch.school_key
    ,schaa.school_annual_attribs_key
    ,st.student_key
    ,staa.student_annual_attribs_key
    ,cd.calendar_date_key
    ,sd.school_dates_key
    ,tsc.test_record_type
    ,tst.test_type
    ,tsc.test_admin_period
    ,adm.rolling_admin_nbr
    ,cd.date_value 
    ,trg.test_benchmark_code as test_primary_result_code
    ,trg.test_benchmark_name as test_primary_result  
    ,tsc.test_secondary_result_code
    ,tsc.test_secondary_result
    ,tsc.test_items_attempted
    ,tsc.test_score_value
    ,tsc.test_raw_score
    ,tsc.test_scaled_score
    ,tsc.test_lower_bound
    ,tsc.test_upper_bound
    ,tsc.test_nce_score
    ,tsc.test_percentile_score
    ,tsc.test_grade_equivalent
    ,tsc.test_reading_level
    ,tsc.test_standard_error
    ,tsc.test_quartile_score
    ,test_decile_score
    ,test_score_text
    ,tsc.test_student_grade
    ,tst.test_subject
    ,tsc.test_admin_period as season
    ,sd.local_school_year as school_year
    ,case when tsc.test_student_grade = 'KG' then 'K5' else tsc.test_student_grade end as grade
    ,trg2.min_value as target_percentile
    ,win.calendar_type
    ,win.start_date
    ,win.end_date
    ,case when cd.date_value between win.start_date and win.end_date then 'Yes' else 'No' end as in_window
    ,row_number() over (partition by st.student_key, tsc.test_admin_period, tst.test_subject order by cd.date_value) as attempt
    ,sysdate
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tsc
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tsc.tests_key
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = tsc.calendar_date_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tsc.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = tsc.school_key
    INNER JOIN K12INTEL_STAGING_MPSENT.ENT_ENTITY_MASTER_VIEW ent on ent.esis_id = to_number(sch.school_code) and to_char(ent.school_year_fall) = substr(sd.local_school_year,1,4)
    LEFT JOIN K12INTEL_DW.MPSD_STAR_WINDOWS win on win.calendar_type = ent.calendar and win.season = tsc.test_admin_period and win.school_year = sd.local_school_year
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on tsc.school_annual_attribs_key = schaa.school_annual_attribs_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on tsc.student_key = st.student_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on staa.student_annual_attribs_key = tsc.student_annual_attribs_key
    INNER JOIN K12INTEL_DW.MPSD_TEST_ADMIN_NUMBER adm on adm.test_type = substr(test_name,1,4) and tsc.test_admin_period = adm.season
    LEFT JOIN K12INTEL_DW.DTBL_TEST_BENCHMARKS trg on trg.tests_key = tst.tests_key
                                                         and tsc.test_percentile_score between trg.min_value and trg.max_value
                                                         and trg.effective_start_date <= cd.date_value 
                                                         and trg.effective_end_date >= cd.date_value
    INNER JOIN K12INTEL_DW.DTBL_TEST_BENCHMARKS trg2 on trg2.tests_key = tst.tests_key and trg2.test_benchmark_code = '2'
WHERE
    tst.test_name like 'STAR%'
    and tst.test_class = 'Component'
    and rownum < 100
    
   ;
   