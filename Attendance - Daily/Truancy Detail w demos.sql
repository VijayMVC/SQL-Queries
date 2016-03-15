SELECT
	tru.*,
	st.student_gender,
	st.student_race
FROM
	DAAADMIN.TRUANT_DETAIL tru
	INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on tru.student_id = st.student_id
WHERE
	tru.year = '2013'

