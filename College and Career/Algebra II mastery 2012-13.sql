SELECT
  tf.collection_year,
  tf.STUDENT_id,
  Alg2.Pass
FROM
  K12INTEL_DW.MPSD_STATE_AIDS tf
		LEFT OUTER JOIN ((select
		distinct st.student_id,
		'Pass' as Pass
	from
		K12INTEL_DW.FTBL_FINAL_MARKS fm
		inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
		inner join K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
		inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
		inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
	--	inner join K12INTEL_DW.XREF_DOMAIN_DECODES xref on  xref.domain_code = c.course_code
		inner join K12INTEL_DW.DTBL_COURSES_EXTENSION ce on ce.course_key=c.course_key
	where
	--	xref.domain_name = 'AP_COURSE_SUBJECT'
		c.course_short_code in ('MA461', 'MA501', 'MA469') and
		fm.mark_numeric_value >=2
	group by
		st.student_id )
INTERSECT
    (select
		distinct st.student_id,
		'Pass'
	from
		K12INTEL_DW.FTBL_FINAL_MARKS fm
		inner join K12INTEL_DW.DTBL_STUDENTS st on st.student_key = fm.student_key
		inner join K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = fm.school_key
		inner join K12INTEL_DW.DTBL_SCHOOL_DATES sd on fm.school_dates_key = sd.school_dates_key
		inner join K12INTEL_DW.DTBL_COURSES c on c.course_key = fm.course_key
	--	inner join K12INTEL_DW.XREF_DOMAIN_DECODES xref on  xref.domain_code = c.course_code
		inner join K12INTEL_DW.DTBL_COURSES_EXTENSION ce on ce.course_key=c.course_key
	where
	--	xref.domain_name = 'AP_COURSE_SUBJECT'
		c.course_short_code in ('MA471', 'MA511', 'MA479')  AND
		fm.mark_numeric_value >= 2
	group by
		st.student_id  )) Alg2 ON Alg2.student_id = tf.student_id
WHERE
	TF.STUDENT_GRADE_CODE  =  '12' and
   TF.COLLECTION_TYPE = 'PRODUCTION' AND
   tf.school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE')  and
   TF.STUDENT_COUNTABLE_INDICATOR = 'Yes'  AND
   TF.COLLECTION_YEAR  =  '2012-2013' AND
   TF.COLLECTION_PERIOD  =  'September 3rd Friday'
