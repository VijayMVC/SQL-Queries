SELECT
     mps_mv_star_component_scores.subject,
     count(distinct dtbl_students.STUDENT_KEY) As students
FROM
    K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS on MPS_MV_STAR_COMPONENT_SCORES.STUDENT_KEY = DTBL_STUDENTS.STUDENT_KEY 
    inner JOIN K12INTEL_DW.DTBL_SCHOOL_DATES on MPS_MV_STAR_COMPONENT_SCORES.SCHOOL_DATES_KEY = DTBL_SCHOOL_DATES.SCHOOL_DATES_KEY 
    inner JOIN K12INTEL_DW.DTBL_CALENDAR_DATES on MPS_MV_STAR_COMPONENT_SCORES.CALENDAR_DATE_KEY = DTBL_CALENDAR_DATES.CALENDAR_DATE_KEY 
    inner JOIN K12INTEL_DW.DTBL_SCHOOLS on MPS_MV_STAR_COMPONENT_SCORES.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY 
WHERE
     dtbl_school_dates.local_school_year = '2015-2016'
     and EXISTS 
        (SELECT 1 -- count(*), student_key, subject, season, school_year 
        FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES sc
         WHERE sc.student_key = MPS_MV_STAR_COMPONENT_SCORES.student_key
               and sc.subject = MPS_MV_STAR_COMPONENT_SCORES.subject
               and sc.school_year = MPS_MV_STAR_COMPONENT_SCORES.school_year
               and (sc.in_window = 'No' or sc.attempt > 2)
--         GROUP BY student_key, subject, season, school_year
--         HAVING count(*) > 1     
             )
GROUP BY
    mps_mv_star_component_scores.subject