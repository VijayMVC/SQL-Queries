SELECT
	sT.SCHOOL_CODE,
	sch.school_name,
	st.year || '-' || to_number(st.year+1) AS SCHOOL_YEAR,
	COUNT (DISTINCT ST.STUDENT_ID) AS Returning_students,
	STD.COUNT AS EXPECTED_TO_RETURN,
	round (COUNT (DISTINCT ST.STUDENT_ID)/STD.COUNT, 3) AS STABILITY_RATE
FROM
	DAAADMIN.STABILITY_DETAIL ST
	inner join DAAADMIN.STABILITY_DENOMINATOR STD on st.school_code = std.school_code and st.year = std.year
	inner join K12INTEL_DW.DTBL_SCHOOLS sch on trim(leading 0 from st.school_code) = sch.school_code
WHERE
	ST.YEAR IN ('2009', '2010', '2011', '2012')
GROUP BY
	sT.SCHOOL_CODE,
	sch.school_name,
	st.year,
	STD.COUNT
ORDER BY
2,3
