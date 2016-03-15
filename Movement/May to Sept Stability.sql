SELECT
    sch.school_code
    ,sch.school_name
    ,first_date.collection_year
    ,count(distinct first_date.student_key) as may_students
    ,count(distinct sec_date.student_key) as sept_students
    ,round(count(distinct sec_date.student_key)/count(distinct first_date.student_key),3) as may_sept_stability_rate
FROM
    (
    SELECT
        sa.student_key
        ,sa.countable_school_code
        ,sa.countable_school_key
        ,sa.student_grade_code
        ,sa.collection_year
    FROM
        K12INTEL_DW.MPSD_STATE_AIDS sa
    WHERE 1=1
        and sa.collection_type = 'PRODUCTION'
        and sa.collection_period = 'May 3rd Friday'
        and sa.student_countable_indicator = 'Yes'
        ) first_date
LEFT OUTER JOIN
    (
    SELECT
        sa.student_key
        ,sa.countable_school_key
        ,sa.countable_school_code
        ,sa.student_grade_code
        ,sa.collection_year
    FROM
        K12INTEL_DW.MPSD_STATE_AIDS sa
    WHERE 1=1
        and sa.collection_type = 'PRODUCTION'
        and sa.collection_period = 'September 3rd Friday'
        and sa.student_countable_indicator = 'Yes'
        ) sec_date on first_date.student_key = sec_date.student_key 
                and sec_date.countable_school_code = first_date.countable_school_code
                and substr(sec_date.collection_year,6,4) = substr(first_date.collection_year,6,4) + 1
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on school_key = first_date.countable_school_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = first_date.student_key
    INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_key = first_date.countable_school_key and schaa.school_year = first_date.collection_year
WHERE 1=1
--   and may.countable_school_code = '76'
   and first_date.collection_year in ('2012-2013', '2013-2014', '2014-2015')
   and schaa.reporting_school_ind = 'Y'
   and first_date.student_grade_code not in ('HS', 'K3', 'K4')
   and NOT EXISTS
        (SELECT 1 
        FROM K12INTEL_STAGING_MPSENT.ENT_ENTITY_MASTER_VIEW  ent
        WHERE to_char(ent.esis_id) = sch.school_code
              and ent.school_year_fall = substr(first_date.collection_year,1,4)
              and ent.active_grades_high = first_date.student_grade_code)
GROUP BY
    sch.school_code
    ,sch.school_name
    ,first_date.collection_year
ORDER BY
    2,3
