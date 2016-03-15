SELECT DISTINCT
  	st.student_id,
  	d.school_key,
  	id.LOCAL_SCHOOL_YEAR as incident_year,
  	saa.school_code,
  	saa.school_name,
  	d.discipline_key,
  	d.discipline_fed_offense_group,
  	d.discipline_state_action_group,
  	d.discipline_dist_offense_group,
  	d.discipline_offense_type,
  	d.discipline_offense_location,
  	d.discipline_offense_reporter,
  	D.discipline_action_type,
  	d.discipline_action_date,
  	da.discipline_action_key,
  	da.discipline_start_date,
  	da.discipline_end_date,
  	da.discipline_action_type_code,
  	da.discipline_action_type,
  	da.discipline_action_assignor,
  	da.discipline_days
FROM
  K12INTEL_DW.FTBL_DISCIPLINE d
  LEFT OUTER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_Key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on d.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  ad on ad.school_dates_key = da.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  id on id.school_dates_key = d.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa ON d.school_key = saa.school_key and id.local_school_year = saa.school_year
WHERE
   ID.local_school_year IN ('2014-2015')
   and (da.discipline_action_type = 'Expulsion/SERVICES'
   or d.discipline_action_type = 'Expulsion/SERVICES')
--   and saa.reporting_school_ind = 'Y'
--   and saa.school_code = '81'
--GROUP BY
----	st.student_id,
--	d.school_key,
--	saa.school_code,
--  	saa.school_name,
--	id.LOCAL_SCHOOL_YEAR
ORDER BY
1,5
