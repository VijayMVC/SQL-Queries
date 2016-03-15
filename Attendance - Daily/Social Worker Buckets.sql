  SELECT MAX (dtbl_students.student_id) AS "C1960",
         dtbl_students.student_name AS "C1933",
         dtbl_students.student_current_grade_code AS "C1934",
         dtbl_students.student_gender AS "C1961",
         dtbl_students.student_age AS "C426",
         CASE WHEN dtbl_students.Student_special_ed_indicator = 'Yes' THEN 'SwD' ELSE 'SwoD' END AS "C1962",
         dtbl_students.STUDENT_ESL_INDICATOR AS "C1963",
         CASE WHEN DTBL_STUDENTS.STUDENT_ESL_CLASSIFICATION = 'Not Applicable' THEN 'NA'
         ELSE DTBL_STUDENTS.student_esl_classification END AS "C1940",
         dtbl_students.STUDENT_FOODSERVICE_INDICATOR AS "C1964",
         TO_CHAR (b.DateValue, 'YYYY-MM-DD') AS "C2156",
         Unex_Abs AS "C6806",
         AbsenceCount AS "C2157"
    FROM 
         K12intel_dw.DTBL_STUDENTS
         INNER JOIN K12INTEL_DW.DTBL_SCHOOLS ON dtbl_students.school_key = dtbl_schools.school_key
         INNER JOIN
         (  SELECT 
                   MPS_MV_ATTEND_YTD_SCHSTUABS.STUDENT_KEY,
                   SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_DAYS) - SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_VALUE)AS Unex_Abs,
                   CASE
                      WHEN   SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_DAYS)
                           - SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_VALUE) BETWEEN 0 AND 4.5 THEN '0-4.5'
                      WHEN   SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_DAYS)
                           - SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_VALUE) BETWEEN 5 AND 7.5 THEN '5-7.5'
                      WHEN   SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_DAYS)
                           - SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_VALUE) BETWEEN 8 AND 24.5 THEN '8-24.5'
                      WHEN   SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_DAYS)
                           - SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_VALUE) BETWEEN 25 AND 34.5 THEN '25-34.5'
                      WHEN   SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_DAYS)
                           - SUM (MPS_MV_ATTEND_YTD_SCHSTUABS.ATTEND_VALUE) > 34.5 THEN '>=35'  END
                      AS AbsenceCount
              FROM K12INTEL_DW.MPS_MV_ATTEND_YTD_SCHSTUABS
                   INNER JOIN k12intel_dw.DTBL_STUDENTS ON DTBL_STUDENTS.student_key =  MPS_MV_ATTEND_YTD_SCHSTUABS.STUDENT_KEY
              WHERE     
                    LOCAL_SCHOOL_YEAR = '2014-2015'
                   AND EXCUSED_ABSENCE IN ('Unexcused')
                   AND DTBL_STUDENTS.STUDENT_ACTIVITY_INDICATOR = 'Active'
            GROUP BY MPS_MV_ATTEND_YTD_SCHSTUABS.STUDENT_KEY) a ON a.student_key = DTBL_STUDENTS.STUDENT_KEY
         INNER JOIN
         (  SELECT 
                    student_key,
                   CASE
                      WHEN MAX (Cumulative) = 35 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 35.5 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 25 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 25.5 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 8 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 8.5 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 5 THEN MAX (DATE_VALUE)
                      WHEN MAX (Cumulative) = 5.5 THEN MAX (DATE_VALUE)
                   END
                      AS DateValue
              FROM 
                (SELECT DISTINCT
                           a.student_key,
                           sd.DATE_VALUE,
                           SUM (CASE WHEN attendance_type = 'FD' THEN 1 ELSE .5 END) OVER (PARTITION BY a.student_key ORDER BY sd.DATE_VALUE) AS Cumulative
                 FROM 
                    k12intel_dw.FTBL_ATTENDANCE a
                    INNER JOIN k12intel_Dw.DTBL_SCHOOL_DATES sd ON a.SCHOOL_DATES_KEY = sd.SCHOOL_DATES_KEY
                           INNER JOIN
                           (  SELECT DISTINCT
                                     a.student_key,
                                     SUM (ATTENDANCE_DAYS - Attendance_value)
                                        AS TotalAbsence
                                FROM k12intel_dw.FTBL_ATTENDANCE_STUABSSUMMARY a
                                     INNER JOIN k12intel_dw.DTBL_STUDENTS
                                        ON DTBL_STUDENTS.student_key =
                                              a.STUDENT_KEY
                               --          Inner join k12intel_Dw.DTBL_SCHOOLS on DTBL_SCHOOLS.school_key = DTBL_STUDENTS.school_key
                               WHERE     ROLLING_LOCAL_SCHOOL_YR_NUMBER = '0'
                                     AND STUDENT_ACTIVITY_INDICATOR = 'Active'
                                     AND EXCUSED_ABSENCE = 'Unexcused'
                                     AND attendance_type <> 'PR'
--                                     AND (dtbl_students.school_key IN ('869'))
--                                     AND dtbl_students.student_id = '8692399'
                            GROUP BY a.student_key
                              HAVING SUM (ATTENDANCE_DAYS - Attendance_value) >
                                        4.5) z
                              ON z.STUDENT_KEY = a.STUDENT_KEY
                   WHERE     
                        sd.ROLLING_LOCAL_SCHOOL_YR_NUMBER = '0'
                         AND local_school_year = '2014-2015'
                         AND EXCUSED_ABSENCE = 'Unexcused'
                        AND attendance_type <> 'PR') a
          WHERE Cumulative IN ('5', '5.5', '8', '8.5', '25', '25.5', '35', '35.5')
          GROUP BY student_key) b ON     b.student_key = DTBL_STUDENTS.student_key AND a.student_key = b.student_key
   WHERE 
        1 = 1 
 
GROUP BY dtbl_students.student_name,
         dtbl_students.student_current_grade_code,
         dtbl_students.student_gender,
         dtbl_students.student_age,
         CASE
            WHEN dtbl_students.Student_special_ed_indicator = 'Yes'
            THEN
               'SwD'
            ELSE
               'SwoD'
         END,
         dtbl_students.STUDENT_ESL_INDICATOR,
         CASE
            WHEN DTBL_STUDENTS.STUDENT_ESL_CLASSIFICATION = 'Not Applicable'
            THEN
               'NA'
            ELSE
               DTBL_STUDENTS.student_esl_classification
         END,
         dtbl_students.STUDENT_FOODSERVICE_INDICATOR,
         TO_CHAR (b.DateValue, 'YYYY-MM-DD'),
         Unex_Abs,
         AbsenceCount
ORDER BY MAX (dtbl_students.student_id),
         dtbl_students.student_name,
         dtbl_students.student_current_grade_code,
         dtbl_students.student_gender,
         dtbl_students.student_age,
         CASE
            WHEN dtbl_students.Student_special_ed_indicator = 'Yes'
            THEN
               'SwD'
            ELSE
               'SwoD'
         END,
         dtbl_students.STUDENT_ESL_INDICATOR,
         CASE
            WHEN DTBL_STUDENTS.STUDENT_ESL_CLASSIFICATION = 'Not Applicable'
            THEN
               'NA'
            ELSE
               DTBL_STUDENTS.student_esl_classification
         END,
         dtbl_students.STUDENT_FOODSERVICE_INDICATOR,
         TO_CHAR (b.DateValue, 'YYYY-MM-DD'),
         Unex_Abs,
         AbsenceCount