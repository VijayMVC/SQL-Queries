/* Formatted on 2/2/2015 3:37:51 PM (QP5 v5.269.14213.34746) */
SELECT CASE
          WHEN active_rows.student_key IS NULL THEN 'Inactive'
          ELSE 'Active'
       END
          STUDENT_AT_RISK_STATUS,
       active_rows.*,
       inactive_rows.*
  FROM (SELECT dtbl_students.STUDENT_KEY,
               dtbl_students.STUDENT_CURRENT_SCHOOL_CODE,
               dtbl_students.STUDENT_CURRENT_GRADE_CODE,
               dtbl_students_evolved.STUDENT_EVOLVE_KEY
          --            || '         ,'|| v_students_at_risk_data.RISK_MEASURE_VALUE_1_LOGIC ||' RISK_FACTOR_MEASURE_VALUE_1 '
          --            || '         ,'|| v_students_at_risk_data.RISK_MEASURE_VALUE_2_LOGIC ||' RISK_FACTOR_MEASURE_VALUE_2 '
          --            || '         ,'|| v_students_at_risk_data.RISK_MEASURE_VALUE_3_LOGIC ||' RISK_FACTOR_MEASURE_VALUE_3 '
          --            || '         ,'|| v_students_at_risk_data.RISK_MEASURE_VALUE_4_LOGIC ||' RISK_FACTOR_MEASURE_VALUE_4 '
          --            || '         ,'|| v_students_at_risk_data.RISK_REPORT_TEXT_1_LOGIC ||' RISK_FACTOR_REPORT_TEXT_1 '
          --            || '         ,'|| v_students_at_risk_data.RISK_REPORT_TEXT_2_LOGIC ||' RISK_FACTOR_REPORT_TEXT_2 '
          FROM K12INTEL_DW.DTBL_STUDENTS dtbl_students
               INNER JOIN
               K12INTEL_DW.DTBL_STUDENTS_EXTENSION dtbl_students_extension
                  ON dtbl_students.student_key =
                        dtbl_students_extension.student_key
               INNER JOIN
               K12INTEL_DW.DTBL_STUDENT_DETAILS dtbl_student_details
                  ON dtbl_students.student_key =
                        dtbl_student_details.student_key
               INNER JOIN K12INTEL_DW.DTBL_SCHOOLS dtbl_schools
                  ON dtbl_students.STUDENT_CURRENT_SCHOOL_CODE =
                        dtbl_schools.school_code
               LEFT JOIN
               K12INTEL_DW.DTBL_STUDENTS_EVOLVED dtbl_students_evolved
                  ON     dtbl_students_evolved.STUDENT_ID =
                            dtbl_students.STUDENT_ID
                     AND SYSDATE BETWEEN dtbl_students_evolved.SYS_BEGIN_DATE
                                     AND dtbl_students_evolved.SYS_END_DATE
         WHERE     (    dtbl_students.STUDENT_ACTIVITY_INDICATOR = 'Active'
                    AND dtbl_students.STUDENT_CURRENT_GRADE_CODE IN ('K5',
                                                                     '01',
                                                                     '02',
                                                                     '03',
                                                                     '04',
                                                                     '05',
                                                                     '06',
                                                                     '07',
                                                                     '08',
                                                                     '09',
                                                                     '10',
                                                                     '11',
                                                                     '12')
                    AND dtbl_student_details.STUDENT_BIRTHDATE <=
                           TO_DATE (
                                 '09/01/'
                              || CAST (
                                      get_sis_school_year_ic ('MPS_IC')
                                    - 6
                                    - CAST (
                                         CASE
                                            WHEN dtbl_students.STUDENT_CURRENT_GRADE_CODE =
                                                    'K5'
                                            THEN
                                               '00'
                                            ELSE
                                               dtbl_students.STUDENT_CURRENT_GRADE_CODE
                                         END AS NUMBER (10)) AS VARCHAR2 (10)),
                              'mm/dd/yyyy'))
               AND dtbl_students.student_id = '8570488'
               AND (    DTBL_SCHOOLS.SYS_DUMMY_IND = 'N'
                    AND (   DTBL_SCHOOLS.SCHOOL_TYPE NOT IN ('@ERR',
                                                             'ADMINISTRATIVE',
                                                             'CHAPTER 220',
                                                             'HEAD START NON-MPS',
                                                             'OPEN ENROLLMENT',
                                                             'PRIVATE',
                                                             'RESIDENTIAL CARE CENTER',
                                                             'Traditional',
                                                             'UNKNOWN')
                         OR     DTBL_SCHOOLS.SCHOOL_TYPE = 'Traditional'
                            AND DTBL_SCHOOLS.STATE_DISTRICT_CODE = '3619'
                            AND DTBL_SCHOOLS.STATE_SCHOOL_AGENCY =
                                   'PUBLIC SCHOOL'))
               AND CASE
                      WHEN NVL (
                              LENGTH (
                                 TRIM (
                                    TRANSLATE (
                                       TRIM (DTBL_SCHOOLS.school_code),
                                       '0123456789',
                                       '          '))),
                              0) = 0
                      THEN
                         CASE
                            WHEN DTBL_SCHOOLS.school_code < 9000 THEN 1
                            ELSE 0
                         END
                      ELSE
                         0
                   END = 1) active_rows
       FULL OUTER JOIN
       (SELECT a.STUDENT_AT_RISK_KEY,
               a.RISK_FACTOR_KEY,
               a.STUDENT_KEY,
               a.STUDENT_EVOLVE_KEY,
               a.SCHOOL_KEY,
               a.SCHOOL_ANNUAL_ATTRIBS_KEY,
               a.CALENDAR_DATE_KEY,
               a.SCHOOL_DATES_KEY,
               a.STUDENT_RISK_IDENTIFIED_DATE,
               a.STUDENT_RISK_EXPIRE_DATE,
               a.STUDENT_RISK_STATUS,
               a.STUDENT_RISK_OUTCOME,
               a.STUDENT_RISK_SEVERITY_SCORE,
               a.STUDENT_RISK_DURATION,
               a.STUDENT_RISK_FACTOR_MET_IND,
               a.STUDENT_RISK_FACTOR_MET_VALUE,
               a.STUDENT_RISK_MEASURE_VALUE,
               a.STUDENT_RISK_MEASURE_VALUE_2,
               a.STUDENT_RISK_REPORT_TEXT,
               a.STUDENT_RISK_NOTES,
               a.DISTRICT_CODE,
               a.SYS_ETL_SOURCE,
               a.SYS_AUDIT_IND
          FROM K12INTEL_DW.FTBL_STUDENTS_AT_RISK a
         WHERE risk_factor_key = 1007 AND a.student_key = 221487)
       inactive_rows
          ON active_rows.student_key = inactive_rows.student_key