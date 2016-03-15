SELECT
    dtbl_schools.school_name,
    dtbl_students.student_current_grade_code,
    xtbl_domain_decodes.domain_decode,
    count(distinct dtbl_students.student_key) as total_students,
    count(case when met_exempt.met_ind in ('Met', 'Exempt') then dtbl_students.student_key else null end) as met_exempt_students    
FROM
    K12INTEL_DW.DTBL_STUDENTS
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS ON DTBL_STUDENTS.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY
    INNER JOIN K12INTEL_USERDATA.XTBL_DOMAIN_DECODES ON dtbl_students.student_current_grade_code = xtbl_domain_decodes.domain_code
                                                    and xtbl_domain_decodes.domain_name = 'GRADE_CODE'
    INNER JOIN
    (SELECT   
        dtbl_students.student_key,
       case when mrk.student_key is not NULL then 'Met' 
                   when (prg.student_key is not NULL 
                        or grad.cohort <= 2014) then 'Exempt'
                   else 'Not Met' end as met_ind
    FROM
          K12INTEL_DW.DTBL_STUDENTS 
          LEFT OUTER JOIN 
          (SELECT 
                distinct ftbl_student_marks.student_key
          FROM 
               K12INTEL_DW.FTBL_STUDENT_MARKS 
               INNER JOIN K12INTEL_DW.DTBL_COURSES ON DTBL_COURSES.COURSE_KEY = FTBL_STUDENT_MARKS.COURSE_KEY
               AND SUBSTR(K12INTEL_DW.DTBL_COURSES.COURSE_CODE,1,5) IN ('AAONL', 'AASER', 'AACOM')
               and ftbl_student_marks.mark_type = 'Final'
               and ftbl_student_marks.mark_credit_value_earned <> 0 ) mrk
                ON DTBL_STUDENTS.STUDENT_KEY = mrk.STUDENT_KEY                       
           LEFT OUTER JOIN
            (SELECT
                dtbl_students.student_key,
                case when dtbl_students.student_graduation_cohort = 0 then (min(sis_school_year) + 4) else dtbl_students.student_graduation_cohort end as cohort
            FROM 
                k12intel_dw.ftbl_enrollments
                inner join k12intel_dw.dtbl_students on dtbl_students.student_key = ftbl_enrollments.student_key
                inner join k12intel_dw.dtbl_school_dates admission_school_dates on ftbl_enrollments.school_dates_key_begin_enroll = admission_school_dates.school_dates_key
                inner join k12intel_dw.dtbl_calendar_dates withdrawal_calendar_dates on ftbl_enrollments.CAL_DATE_KEY_END_ENROLL = withdrawal_calendar_dates.CALENDAR_DATE_KEY
                inner join K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS on ftbl_enrollments.SCHOOL_ANNUAL_ATTRIBS_KEY = DTBL_SCHOOL_ANNUAL_ATTRIBS.SCHOOL_ANNUAL_ATTRIBS_KEY
            WHERE
                (Withdrawal_Calendar_Dates.DATE_VALUE - Admission_School_Dates.DATE_VALUE) > 2
                 and entry_grade_code in ('09','10','11','12')
                 and enrollment_type = 'Actual'
                 and reporting_school_ind = 'Y'
            GROUP BY dtbl_students.student_key, dtbl_students.student_graduation_cohort  ) grad on grad.student_key = dtbl_students.student_key
        LEFT OUTER JOIN
        (SELECT
             distinct FTBL_PROGRAM_MEMBERSHIP.student_key
        FROM
              K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP
              inner join K12INTEL_DW.DTBL_PROGRAMS on K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP.PROGRAM_KEY = K12INTEL_DW.DTBL_PROGRAMS.PROGRAM_KEY
        WHERE
            DTBL_PROGRAMS.PROGRAM_STATUS = 'Active'
            and FTBL_PROGRAM_MEMBERSHIP.MEMBERSHIP_STATUS = 'Active'
            and DTBL_PROGRAMS.PROGRAM_TYPE = 'Diploma' 
            and DTBL_PROGRAMS.PROGRAM_NAME  in ('Cert. of Completion','GEDO2','MPS GED-02 (2004)','MPS GED-02 (2015)')
          )  prg on prg.student_key = dtbl_students.student_key
          ) 
        met_exempt ON met_exempt.student_key = dtbl_students.student_key
 WHERE
        dtbl_students.student_status = 'Enrolled' and dtbl_students.student_activity_indicator = 'Active'
        and dtbl_students.student_current_grade_code in ('09', '10', '11', '12', '12+')
GROUP BY
    dtbl_schools.school_name,
        xtbl_domain_decodes.domain_decode,
    dtbl_students.student_current_grade_code