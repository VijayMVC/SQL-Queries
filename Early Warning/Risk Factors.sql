SELECT DISTINCT
    rf.RISK_FACTOR_NAME, 
    rf.RISK_FACTOR_ABBREV,
    rf.RISK_FACTOR_TYPE, 
    rf.RISK_FACTOR_GROUP, 
    rf.RISK_FACTOR_GRADE_LEVEL, 
    rf.RISK_FACTOR_STATUS, 
    rf.RISK_FACTOR_EFFECTIVE_START, 
    rf.RISK_FACTOR_EFFECTIVE_END, 
    rf.RISK_FACTOR_MEASURE_TYPE,
    xr.RISK_FACTOR_SCOPE,
    xr.RISK_FACTOR_SOURCE_FILTER,
    xr.RISK_FACTOR_CONDITION_CODE,
    xr.RISK_FACTOR_CONDITION_LOGIC, 
    xr.RISK_MEASURE_VALUE_1_LOGIC, 
    xr.RISK_REPORT_TEXT_LOGIC, 
    xr.RISK_REPORT_TEXT_LABEL
FROM
     k12intel_dw.DTBL_RISK_FACTORS rf
 --         inner join  k12intel_dw.FTBL_STUDENTS_AT_RISK sar on sar.RISK_FACTOR_KEY = rf.RISK_FACTOR_KEY
          left outer join k12intel_userdata.xtbl_risk_factors xr on xr.risk_factor_id = rf.risk_factor_id     
WHERE  
----    xr.RISK_FACTOR_SCOPE = 'FTBL_SAR_ATTEND'   
    (rf.RISK_FACTOR_TYPE = 'Students')
ORDER BY
    1
;
SELECT * from k12intel_dw.DTBL_RISK_FACTORS rf
where rf.risk_factor_type = 'Students'
;
select * from k12intel_userdata.xtbl_risk_factors xr --where risk_factor_key = 1007
