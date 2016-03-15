SELECT
--    spr.student_grade_code
    count(spr.student_key)
    ,count(case when fall.student_grade_code = spr.student_grade_code then fall.student_key else null end) as retained
    ,round(count(case when fall.student_grade_code = spr.student_grade_code then fall.student_key else null end)/count(spr.student_key),3) as pct
FROM
    K12INTEL_DW.DTBL_SCHOOLS sch
    INNER JOIN 
    (SELECT
        sa.student_key
        ,sa.countable_school_key
        ,sa.student_grade_code 
    FROM
        K12INTEL_DW.MPSD_STATE_AIDS sa
    WHERE
        sa.collection_period = 'May 3rd Friday' and
        sa.school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE') and
        sa.collection_type = 'PRODUCTION' and
        sa.student_countable_indicator = 'Yes' and
        sa.collection_year in ('2013-2014') and
        sa.student_grade_code != '12'
    ORDER BY
        2,1 ) spr on spr.countable_school_key = sch.school_key
    INNER JOIN
  ( SELECT
        sa.student_key
        ,sa.countable_school_key
        ,sa.student_grade_code 
    FROM
        K12INTEL_DW.MPSD_STATE_AIDS sa
    WHERE
        sa.collection_period = 'September 3rd Friday' and
        sa.school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE') and
        sa.collection_type = 'PRODUCTION' and
        sa.student_countable_indicator = 'Yes' and
        sa.collection_year in ('2014-2015')
    ORDER BY
        2,1 ) fall on fall.student_key = spr.student_key
WHERE
    sch.school_code = '14'
--GROUP BY
--    spr.student_grade_code