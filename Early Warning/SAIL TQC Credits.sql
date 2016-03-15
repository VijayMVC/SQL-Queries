 SELECT
    ar.student_key,
    sch.school_code,
    sch.school_name,
    ar.student_risk_status,
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
WHERE 1=1
   and ar.STUDENT_RISK_STATUS  =  'Active' 
   and ar.student_risk_expire_date <= sysdate  
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
    sch.school_name