SELECT
	reg_sd.local_school_year,
	st.student_id,
	st.student_name,
--	st.student_status,
	sch.school_code,
	sch.school_name
FROM
  K12INTEL_DW.FTBL_ENROLLMENTS enr
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS ST on ENR.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS SCH on sch.school_key = enr.school_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_annual_attribs_key = enr.school_annual_attribs_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  reg_sd on enr.school_dates_key_begin_enroll = reg_sd.school_dates_key
WHERE 1=1
	and schaa.school_year = '2014-2015'
	and sch.school_code in ('9052','9041' )--, '9041')
	and (enr.withdraw_date is null or enr.withdraw_date > sysdate)
--	and st.student_id = '8513383'
Order by 5,3
;
select * from k12intel_dw.dtbl_schools where school_name like 'SUMMER%'
