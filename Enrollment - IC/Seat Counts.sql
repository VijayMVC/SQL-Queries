SELECT
	sch.name,
	cal.name,
	cal.calendarID,
	cal.endyear,
	--seat.*
	sum(seat.generalseats) as gen_seats,
	max(seat.compseats) as comp_seats,
	sum(seat.bilingualseats) as bil_seats,
	sum(seat.eslseats) as esl_seats,
	sum(seat.generalBudget) as gen_budget,
	sum(seat.COMPBudget) as comp_budget,
	sum(seat.bilingualBudget) as bil_budget,
	sum(seat.ESLBudget) as esl_budget,
	(sum(seat.generalseats) + sum(seat.bilingualseats) + sum(seat.ESLSeats) + max(seat.compseats)) as total_paper,
	(sum(seat.generalbudget) + sum(seat.bilingualBudget) + sum(seat.ESLBudget) + max(seat.COMPBudget))  as total_budget 
	--count(distinct res.personid)
FROM 
	dbo.olr_seatCount seat
	INNER JOIN dbo.calendar cal on cal.calendarid = seat.calendarID
	--INNER JOIN dbo.olr_reservedSeats res on res.calendarid = cal.calendarid
	INNER JOIN dbo.schoolyear sy on cal.endyear = sy.endyear
	INNER JOIN dbo.school sch on sch.schoolid = cal.schoolid
WHERE 1=1
--	sy.active = 1
	and sy.endyear = 2016
GROUP BY
	sch.name,
	cal.endyear,
	cal.calendarID,
	cal.name
ORDER BY 
	1
