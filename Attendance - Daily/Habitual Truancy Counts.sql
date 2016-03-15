SELECT   
    COUNT (DISTINCT a.STUDENT_KEY) as students,
    a.school_year
FROM 
    (SELECT 
        FTBL_ATTENDANCE_STUABSSUMMARY.student_Key,
         DTBL_SCHOOLS.SCHOOL_KEY,
         local_school_year as school_year,
         Local_semester,
         CASE
            WHEN SUM (FTBL_ATTENDANCE_STUABSSUMMARY.ATTENDANCE_DAYS) > 0
            THEN 1 ELSE 0
         END
            AS HabitualTruant
    FROM 
        k12intel_dw.FTBL_ATTENDANCE_STUABSSUMMARY
         INNER JOIN k12intel_dw.DTBL_STUDENTS ON DTBL_STUDENTS.student_key = FTBL_ATTENDANCE_STUABSSUMMARY.STUDENT_KEY
         INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on ftbl_attendance_stuabssummary.student_annual_attribs_key = dtbl_student_annual_attribs.student_annual_attribs_key
         INNER JOIN k12intel_dw.DTBL_SCHOOLS ON FTBL_ATTENDANCE_STUABSSUMMARY.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY
         INNER JOIN k12intel_dw.DTBL_SCHOOLS_EXTENSION ON DTBL_SCHOOLS_EXTENSION.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY
    WHERE     
        local_school_year in ('2011-2012', '2012-2013', '2013-2014')
        AND excused_absence IN ('Unexcused Absence',
                                 'Un-Excused Absence',
                                 'Unexcused')
         AND attendance_type = 'FD'
         and student_annual_grade_code not in ('HS', 'K3', 'K2', 'K4')
    GROUP BY FTBL_ATTENDANCE_STUABSSUMMARY.student_Key,
             DTBL_SCHOOLS.SCHOOL_KEY,
             Local_semester,
             local_school_year
    HAVING SUM (FTBL_ATTENDANCE_STUABSSUMMARY.ATTENDANCE_DAYS) > 4.5) a
GROUP BY
    a.school_year

