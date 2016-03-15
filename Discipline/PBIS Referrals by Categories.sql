SELECT
    enr.school_code,
    enr.school_name,
    enr.school_key,
    enr.local_school_year,
    sum(enr.students) as enrolled_students,
    sum(disc.referrals) as total_referrals, 
    sum(disc.students) as referred_students,
    sum(enr.students) - sum(disc.students) + sum(case when disc.grp = '0-1' then disc.students else 0 end) as referrals_0_1,
    sum(case when disc.grp = '2-5' then disc.students else 0 end) as referrals_2_5,
    sum(case when disc.grp = '6+' then disc.students else 0 end) as referrals_6,
    round(sum(disc.students)/enr.students, 3) as pct_all_students_referred,
    round(sum(case when disc.sped <> 'Yes' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_swod,
    round(sum(case when disc.sped = 'Yes' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_swd,
    round(sum(case when disc.race = 'American Indian or Alaska Native' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_ind_alaskan,
    round(sum(case when disc.race = 'Asian' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_asian,
    round(sum(case when disc.race = 'Black or African American' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_black,
    round(sum(case when disc.race = 'Hispanic' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_hispanic,
    round(sum(case when disc.race = 'White' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_white,
    round(sum(case when disc.race = 'Native Hawaiian or Other Pacific Islander' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_hi_pi,
    round(sum(case when disc.race = 'Multi' then disc.referrals else 0 end)/ sum(disc.referrals),3) as pct_referrals_multi  
FROM
  (SELECT
        enr.student_key,
        enr.school_key,
        sch.school_code,
        sch.school_name,
        adm_sd.local_school_year,
        count(distinct enr.student_key) as students
   FROM
        K12INTEL_DW.FTBL_ENROLLMENTS enr
        INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = enr.school_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON adm_sd.school_dates_key = enr.school_dates_key_begin_enroll
        INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES b_cd ON b_cd.calendar_date_key = enr.cal_date_key_begin_enroll
        INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES e_cd ON e_cd.calendar_date_key = enr.cal_date_key_end_enroll
   WHERE
         enr.ENROLLMENT_TYPE = 'Actual'
         AND e_cd.date_value - adm_sd.date_value > 2
         AND e_cd.month_of_year != '7'
         and sch.reporting_school_ind = 'Y'
--         and sch.school_code in ('316', '76', '73', '42', '98', '104', '113', '117', '122', '170', '212',
--                                '218', '223', '256', '268', '140', '146', '167', '277', '289', '319', '360',
--                                '154', '390', '85', '397', '398')
   GROUP BY
        enr.student_key,
        enr.school_key,
        sch.school_code,
        sch.school_name,
        adm_sd.local_school_year) enr 
  LEFT OUTER JOIN  (
    SELECT
        d.student_key,
        st.student_race as race,
        staa.student_special_ed_indicator as sped,
        d.school_key,
        sd.local_school_year,
        COUNT(d.discipline_key) AS referrals,
        count(distinct d.student_key) as students,
        case when COUNT(d.discipline_key) between 2 and 5 then '2-5'
              when COUNT(d.discipline_key) > 5 then '6+'
              else '0-1' end as grp
    FROM
      K12INTEL_DW.FTBL_DISCIPLINE d
   --   INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key and da.discipline_action_type = 'Suspension'
      INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  sd ON sd.school_dates_key = d.school_dates_key
      INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa ON d.student_annual_attribs_key = staa.student_annual_attribs_key
      INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = d.student_key
     GROUP BY
        d.student_key,
        d.school_key,
        sd.local_school_year,
        st.student_race,
        staa.student_special_ed_indicator) disc
         ON disc.school_key = enr.school_key 
         and enr.student_key = disc.student_key
        AND enr.local_school_year = disc.local_school_year
WHERE
   enr.local_school_year IN ('2014-2015', '2013-2014', '2012-2013', '2011-2012', '2010-2011', '2010-2009')
GROUP BY
    enr.school_code,
    enr.school_name,
    enr.school_key,
    enr.local_school_year,
    enr.students
ORDER BY
2,4