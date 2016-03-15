SELECT 
    st.student_id,
    st.student_age,
    stx.student_years_in_high_school,
    st.student_cumulative_gpa,
    student_esl_classification as ELL, 
    student_foodservice_indicator as EconDisadv, 
    student_educational_Except_Typ as SpEd,
    st.student_current_school_code,
    st.student_current_grade_code,
    all_risk.*
FROM
    K12INTEL_DW.DTBL_STUDENTS st
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = st.school_key
    INNER JOIN
    (SELECT
        risk.student_key,
        max(case when risk.risk_factor_type = 'Students' then risk_level end) as over_age_risk_level,
        max(case when risk.risk_factor_type = 'Attendance' then risk_level end) as attendance_risk_level,
        max(case when risk.risk_factor_type = 'Attendance' then round((student_risk_measure_value * 100), 1) end) as attendance_value,
        max(case when risk.risk_factor_type = 'Behavior' then risk_level end) as behavior_risk_level,
        max(case when risk.risk_factor_type = 'Behavior' then student_risk_measure_value END) as behavior_value,
        max(case when risk.risk_factor_type = 'Credits' then risk_level end) as credits_risk_level,
        max(case when risk.risk_factor_type = 'Credits' then student_risk_measure_value END) as credits_value,
        max(case when risk.risk_factor_type = 'GPA' then risk_level end) as gpa_risk_level,
        max(case when risk.risk_factor_type = 'GPA' then round(student_risk_measure_value,2) end) as gpa_value,
        max(case when risk.risk_factor_type = 'GPA_SS' then risk_level end) as gpa_ss_risk_level,
        max(case when risk.risk_factor_type = 'GPA_SS' then round(student_risk_measure_value,2) end) as gpa_ss_value,
        max(case when risk.risk_factor_type = 'GPA_SC' then risk_level end) as gpa_sc_risk_level,
        max(case when risk.risk_factor_type = 'GPA_SC' then round(student_risk_measure_value,2) end) as gpa_sc_value,
        max(case when risk.risk_factor_type = 'GPA_MA' then risk_level end) as gpa_ma_risk_level,
        max(case when risk.risk_factor_type = 'GPA_MA' then round(student_risk_measure_value,2) end) as gpa_ma_value,
        max(case when risk.risk_factor_type = 'GPA_EN' then risk_level end) as gpa_en_risk_level, 
        max(case when risk.risk_factor_type = 'GPA_EN' then round(student_risk_measure_value,2) end) as gpa_en_value 
     FROM 
      (SELECT
           FTBL_STUDENTS_AT_RISK.STUDENT_KEY,
           case when RISK_FACTOR_TYPE in ('Behavior', 'Attendance', 'Students','Credits') then risk_factor_type 
           when Risk_Factor_ID = 'SLGPAGRDTT' then 'GPA' 
           when Risk_Factor_ID = 'SLGPAGRDSS' then 'GPA_SS' 
           when Risk_Factor_ID = 'SLGPAGRDSC' then 'GPA_SC' 
           when Risk_Factor_ID = 'SLGPAGRDMA' then 'GPA_MA' 
           when Risk_Factor_ID = 'SLGPAGRDEN' then 'GPA_EN' else 'Other' end Risk_Factor_Type ,
           case 
                     when student_risk_measure_value = 1 and DTBL_RISK_FACTORS.RISK_FACTOR_TYPE = 'Students' then 'High Risk' 
                     when student_risk_measure_value <> 1 and DTBL_RISK_FACTORS.RISK_FACTOR_TYPE = 'Students' then 'Low Risk' 
                     when STUDENT_RISK_REPORT_TEXT like 'High%' then 'High Risk' 
                     when STUDENT_RISK_REPORT_TEXT like 'Mod%' then 'Moderate Risk' 
                     when STUDENT_RISK_REPORT_TEXT like 'Low%' then 'Low Risk' else STUDENT_RISK_REPORT_TEXT  end Risk_Level, 
             student_risk_measure_value 
        FROM 
           k12intel_dw.FTBL_STUDENTS_AT_RISK 
                inner join k12intel_dw.DTBL_RISK_FACTORS on FTBL_STUDENTS_AT_RISK.RISK_FACTOR_KEY = DTBL_RISK_FACTORS.RISK_FACTOR_KEY 
        WHERE 
           (STUDENT_RISK_STATUS = 'Active' )
            AND 
        ( 
                DTBL_RISK_FACTORS.RISK_FACTOR_TYPE in ('Behavior', 'Attendance', 'Students') 
                or  DTBL_RISK_FACTORS.RISK_FACTOR_ID  in ('SLTCTOTHS','SLGPAGRDTT') --Credits and GPA 
                or  DTBL_RISK_FACTORS.RISK_FACTOR_ID  in ('SLGPAGRDSS','SLGPAGRDSC','SLGPAGRDMA','SLGPAGRDEN' ))
                ) risk
         GROUP BY
            risk.student_key
         )all_risk on all_risk.student_key = st.student_key
WHERE
    st.student_status = 'Enrolled'
    and st.student_current_grade_code in ('09', '10', '11', '12') 
    and sch.reporting_school_ind = 'Y'
 
 and case when rf.risk_factor_type = 'Students' then 'Over Age' when rf.risk_factor_id = 'SLGPAGRDTT' then 'GPA' else rf.risk_factor_type end",IN,IN,"1=1",string)
     case when rf.risk_factor_type = 'Students' then (case when r.student_risk_measure_value =1 then 'High Risk' else 'Low Risk' end) when r.student_risk_report_text like 'High%' then 'High Risk' when r.student_risk_report_text like 'Mod%' then 'Moderate Risk' when r.student_risk_report_text like 'Low%' then 'Low Risk' else r.student_risk_report_text end",IN,IN,"1=1",string))