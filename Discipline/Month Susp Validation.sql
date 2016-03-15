SELECT DISTINCT
  acd.local_school_year,
  st.student_key,
  st.student_id,
  count(da.discipline_key) as suspension_count,
  susp.counts as mv_susp
FROM
  K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on da.student_evolve_key = ste.student_evolve_key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on da.student_key = st.student_key
--  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  acd on da.school_dates_key = acd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on da.school_key = sch.school_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
  LEFT OUTER JOIN 
    (SELECT susp.student_key, susp.local_school_year, sum(suspension_count) as counts
    FROM K12INTEL_DW.MPS_MV_SUSP_SUM_MONTH susp 
    GROUP BY susp.student_key, susp.local_school_year ) susp on susp.student_key = st.student_key and susp.local_school_year = acd.local_school_year
WHERE
	da.DISCIPLINE_ACTION_TYPE_CODE IN ('33', '37', 'OS', 'OSS')
--    ste.student_current_grade_code in ('09', '10', '11', '12')
--    and st.student_id = '8426610'
    AND acd.local_school_year IN ('2014-2015')
GROUP BY
  st.student_id,
  ST.STUDENT_KEY,
  acd.local_school_year,
  susp.counts
HAVING
    susp.counts <>  count(da.discipline_key)
ORDER BY
1
