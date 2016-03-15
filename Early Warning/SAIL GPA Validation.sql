SELECT
    st.student_key,
    st.student_id,
    st.student_key,
    st.student_name,
    st.student_age,
    stx.student_years_in_high_school,
    st.student_current_grade_code,
    st.student_current_school,
    sail_gpa.school_name as sail_school,
    st.student_cumulative_gpa,
    sail_gpa.risk_factor_name,
    sail_gpa.risk_level,
    sail_gpa.sail_gpa,
    GPA.sail_gpa as sail2_gpa,
    gpa.full_gpa,
    student_risk_identified_date,
    student_risk_expire_date
FROM
    K12INTEL_DW.DTBL_STUDENTS st
    INNER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS std ON  st.student_key = std.student_key
    INNER JOIN k12intel_dw.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
    LEFT OUTER JOIN 
        ( SELECT
            ar.student_key,
            sch.school_code,
            sch.school_name,
            rf.risk_factor_name,
            ar.student_risk_report_text as risk_level,
            ar.student_risk_identified_date,
            ar.student_risk_expire_date,
            ar.STUDENT_RISK_MEASURE_VALUE as sail_gpa
        FROM
          K12INTEL_DW.FTBL_STUDENTS_AT_RISK ar
          INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = ar.school_key
          INNER JOIN K12INTEL_DW.DTBL_RISK_FACTORS rf ON rf.RISK_FACTOR_KEY = ar.RISK_FACTOR_KEY
        WHERE
           ar.STUDENT_RISK_STATUS  =  'Active'   
           and rf.risk_factor_id = 'SLGPAGRDTT'
         ) sail_gpa ON (st.student_key = sail_gpa.student_key)
    INNER JOIN 
        (SELECT
            fmrk.student_key, 
           -- DOMAIN_DECODE subject, 
            sum(mark_credit_value_earned) mark_credit_value_earned,  
            sum(mark_credit_value_attempted) mark_credit_value_attempted,
            sum(case when substr(c.COURSE_STATE_EQUIVILENCE_CODE, 6, 1) = 'B' then MARK_CREDIT_VALUE_EARNED / 2 else MARK_CREDIT_VALUE_EARNED end * s.SCALE_POINT_VALUE) grade_points,
            sum(case when substr(c.COURSE_STATE_EQUIVILENCE_CODE, 6, 1) = 'B' then MARK_CREDIT_VALUE_EARNED else null end * s.SCALE_POINT_VALUE) halved_grade_points,
            sum(MARK_CREDIT_VALUE_EARNED * s.SCALE_POINT_VALUE) full_grade_points,
            sum(case when substr(c.COURSE_STATE_EQUIVILENCE_CODE, 6, 1) = 'B' then MARK_CREDIT_VALUE_EARNED / 2 else MARK_CREDIT_VALUE_EARNED end * s.SCALE_POINT_VALUE) / REPLACE(sum(mark_credit_value_attempted),0,NULL) as sail_gpa,
            sum(MARK_CREDIT_VALUE_EARNED * s.SCALE_POINT_VALUE) / replace(sum(mark_credit_value_attempted),0,NULL) as full_gpa
         FROM
                k12intel_dw.ftbl_student_marks fmrk
                inner join k12intel_dw.dtbl_school_dates dsdt on fmrk.SCHOOL_DATES_KEY = dsdt.SCHOOL_DATES_KEY
                inner join k12intel_dw.dtbl_students dstu on fmrk.STUDENT_KEY = dstu.student_key
                inner join k12intel_dw.dtbl_courses c on fmrk.course_key = c.course_key
                inner join k12intel_dw.dtbl_scales s on fmrk.scale_key = s.scale_key
                inner join k12intel_userdata.xtbl_domain_decodes xdd
                    on substr(c.COURSE_STATE_EQUIVILENCE_CODE, 1, 2) = xdd.DOMAIN_CODE
                        and xdd.DOMAIN_NAME = 'TQC_SUBJECTS' and xdd.DOMAIN_ALTERNATE_DECODE IN ('HS Core', 'HS Total')
         WHERE 1=1
                and fmrk.MARK_TYPE = 'Final'
                and fmrk.HIGH_SCHOOL_CREDIT_INDICATOR = 'Yes'
                and SUBSTR(s.scale_abbreviation,1,1) in ('A','B','C','D','F','U')
        GROUP BY fmrk.student_key -- DOMAIN_DECODE
        ) gpa on gpa.student_key = st.student_key
WHERE
    st.student_activity_indicator = 'Active'
    and st.student_status = 'Enrolled'
    and st.student_current_grade_code in ('09','10','11','12')
--    and st.student_Id = '8382093'
--    and st.student_current_school_code = '641'
--    and sail_credits.student_key is null
--    and st.student_id = '8374833'