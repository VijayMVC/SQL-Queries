SELECT
    distinct mob.student_id
FROM
    (SELECT
        mob.local_school_year
        ,sch.school_code
        ,sch.school_name
        ,st.student_id
        ,mob.enter_date
        ,mob.intake_15
        ,mob.end_date
        ,mob.end_enroll_day
        ,mob.withdraw_reason_code
        ,mob.exiter
        ,mob.enrollment_days  
        ,mob.r
    FROM       
        (SELECT
            enr.student_key
            ,enr.student_evolve_key
            ,enr.student_annual_attribs_key
            ,reg_sd.local_school_year
            ,enr.school_key
            ,enr.school_annual_attribs_key
            ,enr.admission_reason_code
            ,reg_sd.date_value as enter_date
            ,reg_sd.local_enroll_day_in_school_yr as start_enroll_day
            ,case when reg_sd.local_enroll_day_in_school_yr >= 15 then 1 else 0 end as intake_15
            ,case when reg_sd.date_value > tfs.aids_date then 1 else 0 end as intake_3rd
            ,enr.withdraw_reason_code
            ,enr.withdraw_date
            ,end_sd.date_value as end_date
            ,end_sd.local_enroll_day_in_school_yr as end_enroll_day
            ,case when enr.withdraw_date is not null and end_sd.local_enroll_day_in_school_yr between 15 and 150 then 1 else 0 end as exiter
            ,enrollment_days
            ,count(*) as enrollment_count
            ,row_number() over (partition by enr.student_key, reg_sd.local_school_year order by reg_sd.date_value) as r
        FROM
            K12INTEL_DW.FTBL_ENROLLMENTS enr
            INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd on enr.school_dates_key_register=reg_sd.school_dates_key
            INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
            INNER JOIN 
                (select distinct sa.collection_date as aids_date, sa.collection_year
                from K12INTEL_DW.MPSD_STATE_AIDS sa
                where sa.collection_period = 'September 3rd Friday') tfs on tfs.collection_year = reg_sd.local_school_year
        WHERE 1=1
             and enr.enrollment_type = 'Actual'
             and extract(month from end_sd.date_value) != 7
             and end_sd.date_value - reg_sd.date_value > 2
        GROUP BY
            enr.student_key
            ,enr.student_evolve_key
            ,enr.student_annual_attribs_key
            ,reg_sd.local_school_year
            ,enr.school_key
            ,enr.school_annual_attribs_key
            ,enr.admission_reason_code
            ,reg_sd.date_value
            ,reg_sd.local_enroll_day_in_school_yr
            ,enr.withdraw_reason_code
            ,end_sd.date_value
            ,end_sd.local_enroll_day_in_school_yr
            ,enr.withdraw_date
            ,enr.enrollment_days
            ,tfs.aids_date
            ) mob
        INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = mob.student_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = mob.school_key
        INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on staa.student_annual_attribs_key = mob.student_annual_attribs_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_annual_attribs_key = mob.school_annual_attribs_key
    WHERE
        schaa.school_year = '2014-2015'
        and schaa.reporting_school_ind = 'Y'
--        and sch.school_code = '76'
    ORDER BY 3,5
    ) mob
WHERE
    mob.intake_15 = 1
;