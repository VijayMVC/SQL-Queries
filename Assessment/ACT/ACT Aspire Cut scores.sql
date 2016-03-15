SELECT
    t.test_subject,
    tsc.test_student_grade,
    tsc.test_primary_result_code,
    tsc.test_primary_result,
    min(tsc.test_scaled_score),
    max(tsc.test_scaled_score) 
FROM
    K12INTEL_DW.FTBL_TEST_SCORES TSC
    INNER JOIN K12INTEL_DW.dtbl_TESTS T on T.TESTS_KEY = TSC.TESTS_KEY 
    INNER JOIN K12INTEL_DW.dtbl_schools sch on sch.school_key = tsc.school_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tsc.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS S ON S.student_key = tsc.student_key 
WHERE
   T.TEST_TYPE IN ('ACTASPIRE') 
   and T.TEST_CLASS  =  'COMPONENT'
   and (sd.local_school_year = '2014-2015')
GROUP BY
    t.test_subject,
    tsc.test_primary_result_code,
    tsc.test_primary_result,
    tsc.test_student_grade
order by 1,2,3