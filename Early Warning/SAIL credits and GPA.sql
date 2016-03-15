SELECT
	st.student_key,
    st.student_id,
	st.student_key,
	st.student_name,
	st.student_age,
    st.student_current_grade_code,
    st.student_current_school,
    sail_credits.school_name as sail_school,
	st.student_cumulative_gpa,
    stx.student_years_in_high_school,
    sail_credits.risk_level,
	sail_credits.credits as sail_credits,
    sail_credits.tot_credits as sail2_credits,
    tot_credits.credits as tot_credits,
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
            ar.student_risk_report_text as risk_level,
            ar.student_risk_identified_date,
            ar.student_risk_expire_date,
            ar.STUDENT_RISK_MEASURE_VALUE as credits,
            sum(fm.mark_credit_value_earned) as tot_credits
	    FROM
          K12INTEL_DW.FTBL_STUDENTS_AT_RISK ar
          INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = ar.school_key
          INNER JOIN K12INTEL_DW.DTBL_RISK_FACTORS rf ON rf.RISK_FACTOR_KEY = ar.RISK_FACTOR_KEY
          INNER JOIN K12INTEL_DW.FTBL_STUDENT_MARKS fm ON fm.student_key = ar.student_key
          INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd on cd.calendar_date_key = fm.calendar_date_key and cd.date_value <= ar.student_risk_identified_date          
		WHERE
           ar.STUDENT_RISK_STATUS  =  'Active'   
           and rf.risk_factor_key = '1045' 
           and fm.mark_type = 'Final'
           and fm.high_school_credit_indicator = 'Yes' 
        GROUP BY
           ar.student_key,
           ar.student_risk_identified_date,
           ar.student_risk_expire_date,
           ar.STUDENT_RISK_MEASURE_VALUE,
           ar.student_risk_report_text,
           sch.school_code,
            sch.school_name  ) sail_credits ON (st.student_key = sail_credits.student_key)
    INNER JOIN 
        (SELECT
            fm.student_key,
            sum(fm.mark_credit_value_earned) as credits
         FROM
            K12INTEL_DW.FTBL_STUDENT_MARKS fm 
         WHERE
            fm.mark_type = 'Final'
            and FM.HIGH_SCHOOL_CREDIT_INDICATOR = 'Yes'
         GROUP BY
            fm.student_key ) tot_credits on (tot_credits.student_key = st.student_key)
WHERE
	st.student_activity_indicator = 'Active'
    and st.student_status = 'Enrolled'
    and st.student_current_grade_code in ('09','10','11','12')
--    and st.student_current_school_code = '641'
--    and sail_credits.student_key is null
--    and st.student_id = '8374833'