SELECT DISTINCT
--  	st.student_id,
  	d.school_key,
  	id.LOCAL_SCHOOL_YEAR as incident_year,
  	saa.school_code,
  	saa.school_name,
	COUNT (DISTINCT d.discipline_key) AS Referrals,
	sum(case when da.DISCIPLINE_ACTION_TYPE = 'Suspension' then 1 else 0 end) as Suspensions
FROM
  K12INTEL_DW.FTBL_DISCIPLINE d
  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_Key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on d.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  ad on ad.school_dates_key = da.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  id on id.school_dates_key = d.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa ON d.school_key = saa.school_key and id.local_school_year = saa.school_year
WHERE
   ID.local_school_year IN ('2014-2015')
   and saa.reporting_school_ind = 'Y'
   and saa.school_code = '81'
GROUP BY
--	st.student_id,
	d.school_key,
	saa.school_code,
  	saa.school_name,
	id.LOCAL_SCHOOL_YEAR
ORDER BY
1,4
