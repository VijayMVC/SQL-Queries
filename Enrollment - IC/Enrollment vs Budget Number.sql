SELECT 
	sch.name as school
	,count (distinct per.studentnumber) as enrolled_students
	,seats.total_budget_seats
	,seats.total_paper_seats
FROM
	dbo.Enrollment enr WITH (NOLOCK)
	INNER JOIN dbo.calendar cal WITH (NOLOCK) on enr.calendarid = cal.calendarid
	INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
	INNER JOIN dbo.schoolyear sy with (NOLOCK) on sy.endyear = cal.endyear
	INNER JOIN dbo.Person per WITH (NOLOCK) on per.personID=enr.personID
	INNER JOIN [dbo].[Identity] id WITH (NOLOCK) on id.identityid = per.currentidentityid
	INNER JOIN 
		(SELECT
			sch.number
			,(sum(seat.generalseats) + sum(seat.bilingualseats) + sum(seat.ESLSeats) + max(seat.compseats)) as total_paper_seats
			,(sum(seat.generalbudget) + sum(seat.bilingualBudget) + sum(seat.ESLBudget) + max(seat.COMPBudget)) as total_budget_seats
		FROM
			dbo.olr_seatCount seat
			INNER JOIN dbo.calendar cal WITH (NOLOCK) on seat.calendarid = cal.calendarid and cal.endyear = 2016
			INNER JOIN dbo.school sch WITH (NOLOCK) on sch.schoolid = cal.schoolid
		GROUP BY
			sch.number
			) seats on seats.number = sch.number
				
WHERE 1=1
	--and per.studentNumber = '8613019'
	and sy.endyear = 2016
	and enr.stateexclude <> 1
	and sch.number not in (9990, 9989, 9988, 9999)
	and (enr.enddate is null or enr.enddate >= getdate()) 
GROUP BY
	sch.name
	,seats.total_budget_seats
	,seats.total_paper_seats
ORDER BY 1
