SELECT
	cal.name as calendar_name,
	sch.name as school_name,
	convert(varchar, cal.startDate, 101) as startdate,
	convert(varchar, cal.endDate, 101) as enddate	
FROM
	dbo.calendar cal
	INNER JOIN dbo.school sch on cal.schoolid = sch.schoolid
	INNER JOIN dbo.schoolYear sy on sy.endYear = cal.endYear
WHERE
	sy.active = 1
	AND cal.summerschool <> 1
ORDER BY
	sch.name, cal.name