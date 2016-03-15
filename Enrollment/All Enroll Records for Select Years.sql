SELECT
	st.student_id,
	--enr.enrollments_key,
	--enr.school_key,
	sch.school_code,
	sch.school_name,
	--schaa.school_code,
	schaa.school_year,
	enr.entry_grade_code,
	enr.CONCURRENT_ENROLLMENT_IND,
	enr.enrollment_type,
	reg_sd.local_school_year,
	adm_cd.date_value as adm_cd,
	reg_sd.date_value as reg_sd,
	reg_cd.date_value as reg_cd,
	end_sd.date_value as end_sd,
	end_cd.date_value as end_cd,
	enr.withdraw_date,
	enr.enrollment_days
FROM
  K12INTEL_DW.FTBL_ENROLLMENTS enr
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS ST on ENR.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION stx on stx.student_key = st.student_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS SCH on sch.school_key = enr.school_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS schaa on schaa.school_annual_attribs_key = enr.school_annual_attribs_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  reg_sd on enr.school_dates_key_begin_enroll = reg_sd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES  reg_cd on enr.cal_date_key_register =reg_cd.calendar_date_key
  INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES  adm_cd on enr.cal_date_key_begin_enroll= adm_cd.calendar_date_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES end_cd on enr.cal_date_key_end_enroll = end_cd.calendar_date_key
WHERE
	schaa.school_year = '2013-2014'
	and enr.entry_grade_code = '08'

Order by 1
-- 	and enr.enrollment_type = 'Actual'
-- 	and schaa.reporting_school_ind = 'Y'
	--st.student_id in ( '8982388')
--	adm_cd.date_value between '07-01-2013' and '06-30-2014'
--	stx.state_student_id in ( '1015081754'
----'1006532639'
----'1025352912',
----'1025175549',
----'1025229703',
----'1025189469',
----'1024205827',
----'1024108414',
----'1024106098',
----'1024130282',
----'1021710407',
----'1024206122',
----'1024129195',
----'1014268907',
----'1006318149',
----'1006318136',
----'1006127053',
----'1006149157',
----'1005785859'
--)
--	enr.enrollments_key = '3162638'
--Order by
--	1,7
--;
--select * from  K12INTEL_DW.FTBL_ENROLLMENTS where enrollments_key = '3162638'
