SELECT
  st.STUDENT_GENDER,
  st.STUDENT_RACE,
  sd.LOCAL_SCHOOL_YEAR,
  count(distinct tsc.STUDENT_key) as student_count
FROM
    K12INTEL_DW.FTBL_TEST_SCORES tsc
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = tsc.student_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst  on tsc.tests_key = tst.tests_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on tsc.school_dates_key = sd.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = tsc.calendar_date_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = tsc.school_annual_attribs_key
WHERE
  (tst.TEST_TYPE  =  'AP TEST'
   AND tst.TEST_CLASS  =  'COMPONENT'
   AND tsc.TEST_SCORE_VALUE  >=  3
   AND sd.ROLLING_LOCAL_SCHOOL_YR_NUMBER  BETWEEN  -3  AND  0
   and st.student_gender = 'Male'
   and st.student_race in ('Hispanic', 'Black or African American', 'Asian')
  )
GROUP BY
  st.STUDENT_GENDER,
  st.STUDENT_RACE,
  sd.LOCAL_SCHOOL_YEAR


