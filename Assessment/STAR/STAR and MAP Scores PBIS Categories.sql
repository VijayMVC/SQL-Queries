SELECT
    map.school_code,
    map.school_name,
    map.school_year,
    map.season,
    case when map.season = 'Fall' then 1 when map.season = 'Spring' then 2 end as season_sort,
--    map.grade_level,
    map.subject,
    sum(map.students) as enrolled_at_test_time_students,
    sum(case when map.result <> '6' then map.students else 0 end) as students_tested,
    round(sum(case when map.result in ('1', '2') then map.students else 0 end)/ sum(map.students), 3) as pct_all_meeting,
    round(sum(case when (map.sped <> 'Yes' and map.result in ('1', '2'))then map.students else 0 end)/ sum(case when map.sped <> 'Yes' then map.students else NULL end),3) as pct_meet_swod,
    round(sum(case when (map.sped = 'Yes' and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.sped = 'Yes' then map.students else NULL end),3) as pct_meet_swd,
    round(sum(case when (map.race = 'American Indian or Alaska Native' and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.race = 'American Indian or Alaska Native' then map.students else NULL end),3) as pct_meet_ind_alaskan,
    round(sum(case when (map.race = 'Asian'  and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.race = 'Asian' then map.students else NULL end),3) as pct_meet_asian,
    round(sum(case when (map.race = 'Black or African American'  and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.race = 'Black or African American' then map.students else NULL end),3) as pct_meet_black,
    round(sum(case when (map.race = 'Hispanic' and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.race = 'Hispanic' then map.students else NULL end),3) as pct_meet_hispanic,
    round(sum(case when (map.race = 'White' and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.race = 'White' then map.students else NULL end),3) as pct_meet_white,
    round(sum(case when (map.race = 'Native Hawaiian or Other Pacific Islander' and map.result in ('1', '2')) then map.students  else 0 end)/ (sum(case when map.race = 'Native Hawaiian or Other Pacific Islander' then map.students else NULL end)),3) as pct_meet_hi_pi,
    round(sum(case when (map.race = 'Multi' and map.result in ('1', '2')) then map.students  else 0 end)/ sum(case when map.race = 'Multi'  then map.students else NULL end),3) as pct_meet_multi
FROM
    (
    SELECT
        tsc.student_key,
        st.student_race as race,
        staa.student_special_ed_indicator as sped,
        tsc.school_key,
        sch.school_code,
        sch.school_name,
        tsc.school_year,
        tsc.season,
        tsc.subject,
        tsc.test_student_grade as grade_level,
        count(distinct tsc.student_key) as students,
        tsc.test_primary_result_code as result
    FROM
      K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES tsc
      INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = tsc.school_key
      INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa ON tsc.student_annual_attribs_key = staa.student_annual_attribs_key
      INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = tsc.student_key
     WHERE 1=1
--        Sch.school_code in ('316', '76', '73', '42', '98', '104', '113', '117', '122', '170', '212',
--                                '218', '223', '256', '268', '140', '146', '167', '277', '289', '319', '360',
--                                '154', '390', '85', '397', '398')
        and tsc.school_year IN ('2014-2015', '2013-2014', '2012-2013')
        and tsc.test_admin_period in ('Fall', 'Spring')
        and tsc.test_student_grade not in ('K4', '12')
        and sch.reporting_school_ind = 'Y'
--        and tsc.subject = 'Reading'
--        and tsc.test_student_grade in ('01', '03', '05', '08')
      GROUP BY
        tsc.student_key,
        st.student_race,
        staa.student_special_ed_indicator,
        tsc.test_student_grade,
        tsc.school_key,
        tsc.subject,
        sch.school_code,
        sch.school_name,
        tsc.school_year,
        tsc.season,
        tsc.test_primary_result_code) map
GROUP BY
    map.school_code,
    map.school_name,
    map.school_year,
    map.subject,
    map.season,
--    map.grade_level,
    case when map.season = 'Fall' then 1 when map.season = 'Spring' then 2 end
ORDER BY
    2,3,7,5 ,6
