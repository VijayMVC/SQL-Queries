SELECT
    enr.school_code,
    enr.school_name,
    enr.school_key,
    staa.school_year,
    count(distinct enr.student_key) as enrolled_students,
    sum(disc.referrals) as total_referrals, 
    count(distinct disc.student_key) as referred_students
FROM
  K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa
  INNER JOIN 
  (SELECT
        enr.student_key,
        enr.school_key,
        sch.school_code,
        sch.school_name,
        adm_sd.local_school_year
   FROM
        K12INTEL_DW.FTBL_ENROLLMENTS enr
        INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = enr.school_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES adm_sd ON adm_sd.school_dates_key = enr.school_dates_key_begin_enroll
        INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES b_cd ON b_cd.calendar_date_key = enr.cal_date_key_begin_enroll
        INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES e_cd ON e_cd.calendar_date_key = enr.cal_date_key_end_enroll
   WHERE
         enr.ENROLLMENT_TYPE = 'Actual'
         AND e_cd.date_value - adm_sd.date_value > 3
         AND e_cd.month_of_year != '7'
         and sch.school_code = '81'
   GROUP BY
        enr.student_key,
        enr.school_key,
        sch.school_code,
        sch.school_name,
        adm_sd.local_school_year) enr 
        ON enr.student_key = staa.student_key and enr.local_school_year = staa.school_year
  LEFT OUTER JOIN  (
    SELECT
        d.student_key,
        d.school_key,
        sd.local_school_year,
        COUNT(d.discipline_key) AS referrals,
        case when COUNT(d.discipline_key) between 2 and 5 then '2-5'
              when COUNT(d.discipline_key) > 5 then '6+'
              else '0-1' end as grp
    FROM
      K12INTEL_DW.FTBL_DISCIPLINE d
      INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  sd ON sd.school_dates_key = d.school_dates_key 
     GROUP BY
         d.student_key,
        d.school_key,
        sd.local_school_year) disc
         ON disc.student_key = staa.student_key 
         and enr.school_key = disc.school_key 
         AND enr.local_school_year = disc.local_school_year
         and disc.local_school_year = staa.school_year
WHERE
   staa.school_year IN ('2013-2014', '2012-2013', '2011-2012')
GROUP BY
    enr.school_code,
    enr.school_name,
    enr.school_key,
    staa.school_year
--    disc.grp
ORDER BY
1,3