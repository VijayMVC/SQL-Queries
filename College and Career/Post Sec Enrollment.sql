SELECT

	,sch.school_name
	,sch.school_code
	,count(distinct pe.student_key) as students
	,count(distinct (case when postsec_enrol_ontime_indicator = 'Yes' and postsec_years_offered = '2' then pe.student_key else null end)) as yr_2_enrolees
	,count(distinct (case when postsec_enrol_ontime_indicator = 'Yes' and postsec_years_offered = '4' then pe.student_key else null end)) as yr_4_enrolees
	,round(count(distinct (case when postsec_enrol_ontime_indicator = 'Yes' and postsec_years_offered = '2' then pe.student_key else null end))/count(distinct pe.student_key),3) as yr_2_rate
	,round(count(distinct (case when postsec_enrol_ontime_indicator = 'Yes' and postsec_years_offered = '4' then pe.student_key else null end))/count(distinct pe.student_key),3) as yr_4_rate
FROM
	K12INTEL_DW.MPSF_POSTSEC_ENROL pe
	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch ON sch.school_key = pe.hs_diploma_school_key
    INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = pe.student_key
WHERE
	hs_diploma_school_year = 2012
--	and st.student_id = '836055'
GROUP BY
	sch.school_name
	,sch.school_code
