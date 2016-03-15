SELECT distinct
    st.student_id,
    st.student_name,
    st.student_current_grade_code,
    sch.school_code,
    sch.school_name,
    enr.school_code as enr_1314_school_code,
    enr.school_Name as enr_1314_school
FROM
    K12INTEL_DW.DTBL_STUDENTS st 
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on st.school_key = sch.school_key    
    INNER JOIN 
    (select distinct tre.pupil_number
     from K12INTEL_STAGING.MPS_SAP_STUDENT_3CHOICE tre
     where
       ( tre.school_choice_1 in ('14')
        or tre.school_choice_2 in ('14')
        or tre.school_choice_3 in ('14'))
        and extract (year from tre.start_date) = '2014' ) tre on tre.pupil_number = st.student_id
    LEFT OUTER JOIN
    (select sch.school_code, sch.school_name, enr.student_key
    from k12intel_dw.ftbl_enrollments enr
        inner join K12INTEL_DW.DTBL_SCHOOLS sch on enr.school_key = sch.school_key
        inner join k12intel_dw.dtbl_school_dates sd on sd.school_dates_key = enr.school_dates_key_register
        inner join k12intel_dw.dtbl_school_dates sd_end on sd_end.school_dates_key = enr.school_dates_key_end_enroll
    where
        sd.date_value <= to_date('05-15-2014', 'MM-DD_YYYY')
        and  sd_end.date_value >= to_date('05-16-2014', 'MM-DD_YYYY')) enr on enr.student_key = st.student_key
WHERE
    sch.school_code = '14'
