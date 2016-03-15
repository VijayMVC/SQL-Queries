SELECT
    pct_white.school_code,
    pct_white.school_name,
    case when pct_white.pct_white is null then 'No Attendance Area' else to_char(pct_white.pct_white) end as pct_white
FROM
    (SELECT
        sch.school_code,
        sch.school_name,
        area.pct as pct_white,
        dense_rank() over (partition by sch.school_code order by area.pct) as rank
    FROM
        K12INTEL_DW.DTBL_SCHOOLS sch
        LEFT OUTER JOIN
        (SELECT
            sch_el.school_code
            ,sch_el.school_name
            ,CASE WHEN st.student_race = 'White' then 'White' else 'Non-White' end as race
        --    ,count(distinct st.student_key) as students
        --    ,sum(count(distinct st.student_key)) over (partition by sch_el.school_code) as total_students 
            ,round(count(distinct st.student_key) / sum(count(distinct st.student_key)) over (partition by sch_el.school_code),2) as pct
        FROM
            K12INTEL_DW.DTBL_STUDENTS st
            INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
            INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch_el on sch_el.school_code = to_char(stx.student_elem_att_area)
        WHERE
            st.student_status = 'Enrolled' and st.student_activity_indicator = 'Active'
            and sch_el.reporting_school_ind = 'Y'
        GROUP BY
            sch_el.school_code
            ,sch_el.school_name
            ,CASE WHEN st.student_race = 'White' then 'White' else 'Non-White' end
        UNION
        SELECT
            sch_mid.school_code
            ,sch_mid.school_name
            ,CASE WHEN st.student_race = 'White' then 'White' else 'Non-White' end as race
        --    ,count(distinct st.student_key) as students
        --    ,sum(count(distinct st.student_key)) over (partition by sch_el.school_code) as total_students 
            ,round(count(distinct st.student_key) / sum(count(distinct st.student_key)) over (partition by sch_mid.school_code),2) as pct
        FROM
            K12INTEL_DW.DTBL_STUDENTS st
            INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
            INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch_mid on sch_mid.school_code = to_char(stx.student_ms_att_area)
        WHERE
            st.student_status = 'Enrolled' and st.student_activity_indicator = 'Active'
            and sch_mid.reporting_school_ind = 'Y'
        GROUP BY
            sch_mid.school_code
            ,sch_mid.school_name
            ,CASE WHEN st.student_race = 'White' then 'White' else 'Non-White' end
        UNION
        SELECT
            sch_hs.school_code
            ,sch_hs.school_name
            ,CASE WHEN st.student_race = 'White' then 'White' else 'Non-White' end as race
        --    ,count(distinct st.student_key) as students
        --    ,sum(count(distinct st.student_key)) over (partition by sch_el.school_code) as total_students 
            ,round(count(distinct st.student_key) / sum(count(distinct st.student_key)) over (partition by sch_hs.school_code),2) as pct
        FROM
            K12INTEL_DW.DTBL_STUDENTS st
            INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
            INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch_hs on sch_hs.school_code = to_char(stx.student_hs_att_area)
        WHERE
            st.student_status = 'Enrolled' and st.student_activity_indicator = 'Active'
            and sch_hs.reporting_school_ind = 'Y'
        GROUP BY
            sch_hs.school_code
            ,sch_hs.school_name
            ,CASE WHEN st.student_race = 'White' then 'White' else 'Non-White' end) area on area.school_code = sch.school_code and area.race = 'White'
    WHERE
        sch.reporting_school_ind = 'Y'
        ) pct_white
WHERE
    pct_white.rank = 1