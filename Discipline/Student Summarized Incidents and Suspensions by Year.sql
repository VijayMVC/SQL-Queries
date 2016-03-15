SELECT DISTINCT
  incd.local_school_year,
  st.student_id,
  count(d.discipline_key) as incident_count,
  count(da.discipline_key) as suspension_count
FROM
  K12INTEL_DW.FTBL_DISCIPLINE d
  LEFT OUTER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
  															and da.DISCIPLINE_ACTION_TYPE  =  'Suspension'
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EVOLVED ste on d.student_evolve_key = ste.student_evolve_key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on d.student_key = st.student_key
--  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  incd on d.school_dates_key = incd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
WHERE
--	da.DISCIPLINE_ACTION_GROUP  =  'Suspension'
    ste.student_current_grade_code in ('09', '10', '11', '12')
    and st.student_id = '8426610'
    AND incd.local_school_year IN ('2014-2015')
GROUP BY
  st.student_id,
  ST.STUDENT_KEY,
  local_school_year
ORDER BY
1
