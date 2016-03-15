SELECT 
	req.requirementID,
	prg.name,
	cs.name,
	cr.courseNumberString,
	req.credits
--	cr.credits
--	sum(req.credits) as credits
FROM 
	DBO.CREDITREQUIREMENT req
	INNER JOIN dbo.program prg on prg.programid = req.programid
	INNER JOIN dbo.CurriculumStandard cs on cs.standardid = req.standardid
	LEFT OUTER JOIN dbo.CourseRequirement cr on cr.standardid = cs.standardid
--GROUP BY
--	prg.name,
--	cs.name
ORDER BY
	1,2
;
select * from dbo.courserequirement
