SELECT
	per.personid,
	per.studentnumber,
	id.firstname,
	id.lastname,
	enr.specialEdStatus,
	lep.programstatus as lep_status,
	sch.number,
	sch.name as school_name,
	cal.name as calendar_name,
	enr.grade,
	convert(date,enr.startdate,101) as start_date,
	enr.startstatus,
	ss.name as startstatus_desc, --attribute 339
	enr.startComments,
	convert(date,enr.enddate,101) as end_date,
	enr.endstatus, --attribute 302
	es.name as endstatus_desc,
	enr.endcomments,
	tr_sch.value as custom_transfer_school,
	tr_dist.value as custom_transfer_district,
	tr_st.value as custom_transfer_state,
	tr_co.value as custom_transfer_country,
	enr_hist.prev_school as prev_MPS_school,
	enr_hist.prev_startdate prev_MPS_start,
	enr_hist.prev_enddate as prev_MPS_end,
	enr_hist.gap
FROM
	dbo.Enrollment enr WITH (NOLOCK)
	INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
	INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
    INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = enr.endyear
    INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
	INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
	LEFT OUTER JOIN dbo.LEP  lep on per.personid = lep.personid
	INNER JOIN dbo.campusdictionary ss on ss.code = enr.startstatus and ss.attributeid = 339
	LEFT OUTER JOIN dbo.campusdictionary es on es.code = enr.startstatus and es.attributeid = 302
	LEFT OUTER JOIN dbo.customstudent tr_sch on tr_sch.enrollmentid = enr.enrollmentid and tr_sch.attributeid = 681
	LEFT OUTER JOIN dbo.customstudent tr_dist on tr_dist.enrollmentid = enr.enrollmentid  and tr_dist.attributeid = 679
	LEFT OUTER JOIN dbo.customstudent tr_st on tr_st.enrollmentid = enr.enrollmentid and tr_st.attributeid = 682
	LEFT OUTER JOIN dbo.customstudent tr_co on tr_co.enrollmentid = enr.enrollmentid and tr_co.attributeid = 683
	INNER JOIN
	(SELECT 
			enr.personid,
			enr.enrollmentID,
			enr.startdate,
			enr.enddate,
			enr.endyear,
			lag(enr.enrollmentID,1) over (order by enr.personid, enr.startdate) as prev_enrollmentid,
			lag(sch.name,1) over (order by enr.personid, enr.startdate) as prev_school,
			lag(enr.endyear,1) over (order by enr.personid, enr.startdate) as prev_endyear,
			lag(enr.startdate,1) over (order by enr.personid, enr.startdate) as prev_startdate,
			lag(enr.enddate,1) over (order by enr.personid, enr.startdate) as prev_enddate,
			datediff(day, enr.startdate, (lag(enr.enddate,1) over (order by enr.personid, enr.startdate))) as gap,
			row_number() over (partition by enr.personid order by enr.startdate desc) as rank
		FROM
			dbo.Enrollment enr WITH (NOLOCK)
			INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
			INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
		WHERE 1=1
			and enr.stateExclude <> 1
			and sch.number not in ('9990', '9989', '9988', '9987','9986')
			and upper(cal.name) not like ('%SUMMER%')
			and enr.startdate <= GETDATE()
		) enr_hist on enr_hist.enrollmentid = enr.enrollmentID
WHERE 1=1
	 and enr.servicetype in ('P', 'S')
	 and sy.active = 1
	 and (enr.specialEdStatus = 'Y' or lep.programstatus = 'LEP')
	 and 
	 (enr.startstatus in ('01', '02', '03', '04', '11', '12', '13', '14', '23')
	 or (enr_hist.prev_enrollmentID is null)
	 or ((MONTH(enr_hist.prev_enddate) not in (6,7) and (enr_hist.prev_endyear = enr.endyear - 1)) and enr_hist.gap <= -90)
	 or ((MONTH(enr_hist.prev_enddate) <> 6 and (enr_hist.prev_endyear = enr.endyear - 1)) AND enr_hist.gap <= -30))
----	 and per.studentNumber = '6330185'
ORDER BY
	2	 