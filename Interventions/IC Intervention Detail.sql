SELECT
    count(distinct student_id)
--    student_id,
--    st.student_name,
--    sch.school_code,
--    sch.school_name,
--    program_type,
--    program_status,
--    PROGRAM_Name,
--    PROGRAM_GROUP,
--    prg.program_intervention_level,
--    prgm.membership_status,
--    px.membership_begin_date,
--    px.membership_end_date,
--    bdsd.date_value as start_date,
--    edsd.date_value as end_date,
--    prgm.membership_days
--    meas.program_measure_class,
--    meas.program_measure_result,
--    meas.program_measure_value,
--    meas.program_measure_text,
--    goal.goal_name,
--    goal.start_date as goal_start,
--    goal.end_date as goal_end,
--    goal.target_value,
--    goal.baseline_value
FROM
    k12intel_dw.ftbl_program_membership prgm
    inner join K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
    left outer JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_EXT px on px.membership_key = prgm.membership_key
--    LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP_GOALS goal on goal.membership_key = prgm.membership_key
--    LEFT OUTER JOIN K12INTEL_DW.FTBL_PROGRAM_MEASURES meas on meas.membership_key = prgm.membership_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = prgm.school_key
    inner join k12intel_dw.dtbl_school_dates bdsd on prgm.begin_school_date_key = bdsd.school_dates_key --and bdsd.rolling_local_school_yr_number = 0
    inner join k12intel_dw.dtbl_school_dates edsd on prgm.end_school_date_key = edsd.school_dates_key
    inner join k12intel_dw.dtbl_students st on prgm.student_key = st.student_key
WHERE
    1=1
--    and membership_begin_date >= to_date('07-01-2015', 'MM-DD-YYYY')
--    and membership_status = 'Active' -- not in ('Expired','Deleted', 'Prior Year Active')
    and program_group in ('Behavior') --, 'Literacy', 'Math')
--    and prg.program_type = 'RTI'
    and bdsd.local_school_year = '2015-2016'
--    and prg.service_focus_subcategory = 'Behavior'
--    and sch.school_code = '73'
--    and st.student_id = '8231531'
--    and meas.program_measure_value is not null
ORDER BY
    1 --,3 --,6, date_value
;
SELECT *
FROM k12intel_dw.FTBL_PROGRAM_MEMBERSHIP
WHERE SYS_ETL_SOURCE = 'BLD_F_PROG_MBRSHP_PLAN_IC'
;
SELECT *
FROM k12intel_dw.DTBL_PROGRAMS
WHERE PROGRAM_TYPE = 'RTI'
  and SYS_ETL_SOURCE = 'BLD_D_PROGRAMS_XTBL'