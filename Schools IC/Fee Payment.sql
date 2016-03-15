SELECT
	id.firstname
	,id.lastname
	,cal.name as calendar
	,fee.name as fee
	,fee.amount
	,case when fp.creditcardauthnumber is not null then 'Credit'
		when fp.checknumber is not null then 'Check'
		else 'Cash' end as payment_type
	,convert(varchar, fp.paymentdate, 101) as payment_date
	,id2.firstname as receiver_firstname
	,id2.lastname as receiver_lastname
FROM
	dbo.fee
	INNER JOIN dbo.feeassignment fa on fee.feeid = fa.feeid
	INNER JOIN dbo.calendar cal on cal.calendarid = fa.calendarid
	INNER JOIN dbo.person per on per.personid = fa.personid
	INNER JOIN dbo.enrollment enr on enr.personid = per.personid and enr.calendarid = cal.calendarid
	INNER JOIN dbo.[identity] id on per.currentidentityid = id.identityid
	INNER JOIN dbo.feecredit fc on fc.assignmentid = fa.assignmentid
	INNER JOIN dbo.feepayment fp on fp.paymentid = fc.paymentid
	INNER JOIN dbo.person per2 on per2.personid = fp.createdbyid
	INNER JOIN dbo.[identity] id2 on per2.currentidentityid = id2.identityid
