SELECT
	SCHOOL_CODE, YEAR, sum(COUNT_ALL)
FROM
	DAAADMIN.RETENTION_SUMMARY
GROUP BY
	SCHOOL_CODE,
	YEAR;

