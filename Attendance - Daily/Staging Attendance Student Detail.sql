--Detail period absence

SELECT
	per.studentNumber,
    per.personid,
	sch."NUMBER",
	sch.name,
    attd.stage_modifydate,
    attd.stage_createdate,
	attd."DATE",
	attd.status,
	attd.excuse,
--	attdx.code,
--	attdx.description,
--	attdx.status,
--	attdx.excuse,
	attd.presentminutes,
    pr.periodminutes,
	attd.comments,
    attd.stage_deleteflag,
    attd.stage_source	
FROM
	k12intel_staging_ic.person per
    INNER JOIN k12intel_staging_ic.attendance attd on attd.personid = per.personid
--    INNER JOIN k12intel_staging_ic.AttendanceExcuse attdx on attd.excuseid = attdx.excuseid and attdx.stage_source = attd.stage_source
    INNER JOIN K12INTEL_STAGING_IC.PERIOD pr  ON attd.PERIODID = pr.PERIODID and pr.stage_source = attd.stage_source
--	INNER JOIN k12intel_staging_ic.enrollment enr on per.personid = enr.personid and enr.stage_deleteflag = 0
	INNER JOIN k12intel_staging_ic.calendar cal on cal.calendarid = attd.calendarid and cal.stage_source = per.stage_source
	INNER JOIN k12intel_staging_ic.schoolyear sy on sy.endyear = cal.endyear and sy.stage_source = cal.stage_source
	INNER JOIN k12intel_staging_ic.school sch on sch.schoolid = cal.schoolid and sch.stage_deleteflag = 0 and sch.stage_source = cal.stage_source
	
WHERE 1=1
	and sy.active = 1
	and per.studentnumber = '8589274'
    and attd.stage_deleteflag = 0
--	and substr(attdx.code,1,1) = 'S'
ORDER BY 
1,7
;
--Day Summarized Absence

SELECT
    per.studentNumber,
    per.personid,
    sch."NUMBER",
    sch.name,
    attd."DATE",
    sum(pr.periodminutes - attd.presentminutes) as missed_minutes,
    cal.halfdayabsence,
    cal.wholedayabsence  
FROM
    k12intel_staging_ic.person per
    INNER JOIN k12intel_staging_ic.enrollment enr on per.personid = enr.personid and enr.stage_deleteflag = 0
    INNER JOIN k12intel_staging_ic.calendar cal on cal.calendarid = enr.calendarid and cal.stage_source = per.stage_source
    INNER JOIN k12intel_staging_ic.schoolyear sy on sy.endyear = cal.endyear and sy.stage_source = cal.stage_source
    INNER JOIN k12intel_staging_ic.school sch on sch.schoolid = cal.schoolid and sch.stage_deleteflag = 0 and sch.stage_source = cal.stage_source
    INNER JOIN k12intel_staging_ic.attendance attd on attd.personid = per.personid and attd.calendarid = cal.calendarid
    INNER JOIN k12intel_staging_ic.AttendanceExcuse attdx on attd.excuseid = attdx.excuseid and attdx.stage_source = attd.stage_source
    INNER JOIN K12INTEL_STAGING_IC.PERIOD pr  ON attd.PERIODID = pr.PERIODID and pr.stage_source = attd.stage_source
WHERE 1=1
    and sy.active = 1
    and per.studentnumber = '8589274'
    and attd.stage_deleteflag = 0
--    and substr(attdx.code,1,1) = 'S'
GROUP BY
    per.studentNumber,
    sch."NUMBER",
    sch.name,
    attd."DATE",
    cal.halfdayabsence,
    cal.wholedayabsence,
    per.personid
ORDER BY 
1,7