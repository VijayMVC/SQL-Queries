SELECT
    sd.local_school_year as school_year
    ,'Total Tested' as Subject
    ,count(distinct tscr.student_key) as total_students
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tscr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT'
WHERE 1=1
--    tscr.test_score_value >= 16
    and tscr.test_student_grade = '11'
GROUP BY
    tst.test_subject
    ,sd.local_school_year
UNION
SELECT
    sd.local_school_year as school_year
    ,tst.test_subject
    ,count(distinct tscr.student_key) as total_students
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tscr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT'  AND
               TST.TEST_SUBJECT = 'Composite' 
WHERE
    tscr.test_score_value >= 16
    and tscr.test_student_grade = '11'
GROUP BY
    tst.test_subject
    ,sd.local_school_year
UNION
SELECT
    sd.local_school_year as school_year
    ,tst.test_subject
    ,count(distinct tscr.student_key) as total_students
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tscr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT'  AND
               TST.TEST_SUBJECT = 'Reading' 
WHERE
    tscr.test_score_value >= 16
    and tscr.test_student_grade = '11'
GROUP BY
    tst.test_subject
    ,sd.local_school_year 
UNION
SELECT
    sd.local_school_year as school_year
    ,tst.test_subject
    ,count(distinct tscr.student_key) as total_students
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tscr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT'  AND
               TST.TEST_SUBJECT = 'Mathematics' 
WHERE
    tscr.test_score_value >= 16
    and tscr.test_student_grade = '11'
GROUP BY
    tst.test_subject
    ,sd.local_school_year                       
UNION
SELECT
    sd.local_school_year as school_year
    ,tst.test_subject
    ,count(distinct tscr.student_key) as total_students
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tscr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT'  AND
               TST.TEST_SUBJECT = 'Science' 
WHERE
    tscr.test_score_value >= 16
    and tscr.test_student_grade = '11'
GROUP BY
    tst.test_subject
    ,sd.local_school_year   
UNION
SELECT
    sd.local_school_year as school_year
    ,tst.test_subject
    ,count(distinct tscr.student_key) as total_students
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tscr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = tscr.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.tests_key = tscr.tests_key and TST.TEST_TYPE  =  'ACT'  AND
               TST.TEST_SUBJECT = 'English' 
WHERE
    tscr.test_score_value >= 16
    and tscr.test_student_grade = '11'
GROUP BY
    tst.test_subject
    ,sd.local_school_year   
  ;