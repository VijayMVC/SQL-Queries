SELECT
    ste.student_id
    ,ste.student_key
    ,reg_sd.local_school_year
    ,schaa.school_code
    ,schaa.school_key
    ,enr.admission_reason_code
    ,reg_sd.date_value as enter_date
    ,reg_sd.local_enroll_day_in_school_yr as start_enroll_day
    ,case when reg_sd.date_value > (select sa.collection_date
                                    from K12INTEL_DW.MPSD_STATE_AIDS sa
                                    where sa.collection_period = '3rd Friday September' and sa.collection_year = reg_sd.local_school_year)
        then 1 else 0 end as Entering_After_3Friday
    ,case when reg_sd.local_enroll_day_in_school_yr >= 15 then 1 else 0 end as Entering_After_15
    ,enr.withdraw_reason_code
    ,enr.withdraw_date
    ,end_sd.date_value as end_date
    ,end_sd.local_enroll_day_in_school_yr as end_enroll_day
    ,case when enr.withdraw_date is not null and end_sd.local_enroll_day_in_school_yr < 150 then 1 else 0 end as Exiting_Before_150
    ,enrollment_days
    ,count(*) as enrollment_count
    ,row_number() over (partition by ste.student_key, reg_sd.local_school_year order by reg_sd.date_value) as r
FROM
    K12INTEL_DW.FTBL_ENROLLMENTS enr
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED STE ON enr.student_evolve_key = ste.student_evolve_key
              INNER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS STD on std.student_key = ste.student_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd on enr.school_dates_key_register=reg_sd.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_annual_attribs_key = enr.school_annual_attribs_key
WHERE
    reg_sd.local_school_year in ('2014-2015')
     and enr.enrollment_type = 'Actual'
     and schaa.reporting_school_ind = 'Y'
     and extract(month from end_sd.date_value) != 7
     and end_sd.date_value - reg_sd.date_value > 2
    --and ste.student_id in ( '8520682')
GROUP BY
    ste.student_id
    ,ste.student_key
    ,schaa.school_code
    ,schaa.school_key
    ,enr.admission_reason_code
    ,reg_sd.local_school_year
    ,schaa.school_code
    ,schaa.school_key
    ,reg_sd.date_value
    ,reg_sd.local_enroll_day_in_school_yr
    ,enr.withdraw_reason_code
    ,end_sd.date_value
    ,end_sd.local_enroll_day_in_school_yr
    ,enr.withdraw_date
    ,enr.enrollment_days
ORDER BY
    ste.student_id
    ,reg_sd.date_value