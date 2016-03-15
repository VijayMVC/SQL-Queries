SELECT
    first_date.collection_year
    ,first_date.student_grade_code
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
        and sa.school_group_sort in ('01', '02', '03', '04', '05', '06', '07', '08')
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
        and sa.school_group_sort in ('01', '02', '03', '04', '05', '06', '07', '08')
        ) sec_date on first_date.student_key = sec_date.student_key 
                and substr(sec_date.collection_year,6,4) = substr(first_date.collection_year,6,4) + 1
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = first_date.student_key
WHERE 1=1
   and first_date.collection_year in ('2012-2013', '2013-2014', '2014-2015')
   and first_date.student_grade_code not in ('HS', 'K2', 'K3', 'K4', '12')
GROUP BY
    first_date.collection_year
    ,first_date.student_grade_code
ORDER BY
    1,2
