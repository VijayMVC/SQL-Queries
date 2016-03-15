SELECT --TOP 1000
--count(*)
	tc.creditID,
	per.studentnumber,
	tr.coursenumber,
	tr.coursename,
	--cm.number,
	--cm.name,
--	cs.name,
--	cs2.name,
	tr.startyear,
	tr.grade,
	tr.date,
	tc.creditcode,
	tc.creditsearned,
	tc.creditsattempted,
	tc.creditRollupOverrideStandardID,
	tr.comments,
	tr.*,
	tc.*,
	case when tr.comments like '%eSIS_Credits_ID%' then 'eSIS' else null end as esis
FROM
	dbo.transcriptcourse tr
	INNER JOIN dbo.transcriptcredit tc on tr.transcriptid = tc.transcriptid
	LEFT JOIN dbo.gradingscore gs on gs.scoreid = tr.scoreid
	--INNER JOIN CurriculumStandard cs on tc.standardid = cs.standardID
	INNER JOIN dbo.person per on per.personid = tr.personid
	--LEFT OUTER JOIN dbo.coursemaster cm on cm.number = substring(tr.coursenumber,1,5)
	--LEFT OUTER JOIN CurriculumStandard cs2 on cs2.legacyKey = substring(cm.number,1,2)			
WHERE 1=1
--	and per.studentnumber = '8219336'
--	per.personid = '253225'
--	and tr.date is null
	and tc.creditid = 11838023
--	AND (tR.comments like '%eSIS_Credits_ID%')
--	and (tR.comments not like '%eSIS_Credits_ID%' or tr.comments is null)
--GROUP BY
--	case when tr.comments like '%eSIS_Credits_ID%' then 'eSIS' else null end
ORDER BY
	1

;
SELECT --TOP 1000
	per.studentnumber,
	cs.name,
	sum(tc.creditsattempted) as attempted,
	sum(tc.creditsearned) as earned	
FROM
	dbo.transcriptcourse tr
	INNER JOIN dbo.transcriptcredit tc on tr.transcriptid = tc.transcriptid
	INNER JOIN CurriculumStandard cs on tc.standardid = cs.standardID
	INNER JOIN dbo.person per on per.personid = tr.personid
	LEFT OUTER JOIN dbo.coursemaster cm on cm.number = substring(tr.coursenumber,1,5)
	LEFT OUTER JOIN CurriculumStandard cs2 on substring(cm.number,1,2) = cs2.legacykey					
WHERE
	per.studentnumber = '8382093'
GROUP BY
	per.studentnumber,
	cs.name
ORDER BY
	1,2
;
SELECT 
	count(*), tr.grade  --5693635 all transcript records in IC
FROM
	dbo.transcriptcourse tr
	INNER JOIN dbo.transcriptcredit tc on tr.transcriptid = tc.transcriptid
	INNER JOIN CurriculumStandard cs on tc.standardid = cs.standardID
	INNER JOIN dbo.person per on per.personid = tr.personid
	LEFT OUTER JOIN dbo.coursemaster cm on cm.number = substring(tr.coursenumber,1,5)
	LEFT OUTER JOIN CurriculumStandard cs2 on substring(cm.number,1,2) = cs2.legacykey
GROUP BY tr.grade