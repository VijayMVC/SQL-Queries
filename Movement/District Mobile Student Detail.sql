SELECT
    count(distinct st.student_key) as students_served
    ,count(distinct case when first_enroll = 1 and intake_3rd = 1 then st.student_key end) as in_take_3rd
    ,count(distinct case when last_enroll = 1 and exiter = 1 then st.student_key end) as exiter
    ,count(distinct case when (first_enroll = 1 and intake_3rd = 1) or (last_enroll = 1 and exiter =1) then st.student_key end) as mobile
    ,round(count(distinct case when first_enroll = 1 and intake_3rd = 1 then st.student_key end)/count(distinct st.student_key),3) as in_3rd_take_rate
    ,round(count(distinct case when last_enroll = 1 and exiter = 1 then st.student_key end)/count(distinct st.student_key),3) as exit_rate
    ,round(count(distinct case when (first_enroll = 1 and intake_3rd = 1) or (last_enroll = 1 and exiter =1) then st.student_key end)/count(distinct st.student_key),3) as churn_rate
FROM
   (SELECT
        mob.local_school_year
        ,mob.student_key
        ,mob.enter_date
        ,mob.intake_15
        ,mob.intake_3rd
        ,mob.end_date
        ,mob.end_enroll_day
        ,mob.withdraw_reason_code
        ,mob.exiter
        ,mob.enrollment_days  
        ,mob.first_enroll
        ,mob.last_enroll
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
            ,row_number() over (partition by enr.student_key, reg_sd.local_school_year order by reg_sd.date_value) as first_enroll
            ,row_number() over (partition by enr.student_key, reg_sd.local_school_year order by reg_sd.date_value desc) as last_enroll
        FROM
            K12INTEL_DW.FTBL_ENROLLMENTS enr
            INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd on enr.school_dates_key_register=reg_sd.school_dates_key
            INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
            INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_annual_attribs_key = enr.school_annual_attribs_key
            INNER JOIN 
                (select distinct sa.collection_date as aids_date, sa.collection_year
                from K12INTEL_DW.MPSD_STATE_AIDS sa
                where sa.collection_period = 'September 3rd Friday') tfs on tfs.collection_year = reg_sd.local_school_year
        WHERE 1=1
             and enr.enrollment_type = 'Actual'
             and extract(month from end_sd.date_value) != 7
             and end_sd.date_value - reg_sd.date_value > 2
             and schaa.reporting_school_ind = 'Y'
            ) mob
    WHERE 1=1
        and mob.local_school_year = '2014-2015'
        and (mob.first_enroll = 1 or mob.last_enroll = 1)
    ) mob
        INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = mob.student_key
        INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on staa.student_key = st.student_key and staa.school_year = mob.local_school_year
;