SELECT
	 crsm.number as course_code,
	 crsm.name as course,
	 crsm.transcript,
	 crsm.active,
	 crsm.activitycode,
	 crsm.type,
	 cs.name
FROM
	dbo.coursemaster crsm
	INNER JOIN CurriculumStandard cs on substring(crsm.number,1,2) = cs.legacykey
	--LEFT OUTER JOIN (DBO.CREDITREQUIREMENT req
	--					INNER JOIN dbo.program prg on prg.programid = req.programid) ON cs.standardid = req.standardid
WHERE
	1=1
	and crsm.transcript = 1
	and crsm.number = 'EN281'