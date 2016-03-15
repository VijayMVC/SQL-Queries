select

	cast(getdate() as date),
	e.personid,
	p.studentnumber,
	e.grade,

	(
	select top(1) AddressOrder.addressid
	from
		(
		select top(1)
			p.personid,
			case when a.addressid is null then 0 else 1 end as addrnull,
			case when hm.personid = rp.personid1 then 0 else 1 end as hm_enrolled,   -- this puts enrolled students records before the related persons records
			isnull(hm.secondary,0) as hm_secondary,
			isnull(hl.secondary,0) as hl_secondary,
			isnull(rp.seq,255) as rp_seq,
			isnull(hm.guardian,0)  as hm_guardian,
			isnull(rp.guardian,0)  as rp_guardian,
			hm.mailing as hm_mailing,
			rp.mailing as rp_mailing,
			a.postofficebox,
			a.number as address_number,
			rp.name as rp_name,
			a.addressid
		from
			dbo.Person p WITH (NOLOCK)
				LEFT OUTER JOIN relatedpair rp WITH (NOLOCK)
					on rp.personid1 = p.personid
							AND (rp.startdate is null or rp.startdate <= GETDATE() )
							AND (rp.enddate is null or rp.endDate >= cast(GETDATE() as date) )
				LEFT OUTER JOIN dbo.HouseholdMember hm WITH (NOLOCK)
					ON (hm.startDate IS NULL OR hm.startDate <= GETDATE() )
						AND (hm.endDate IS NULL OR hm.endDate >= cast(GETDATE() as date) )
						AND (hm.personID = p.personID or hm.personid = rp.personid2)  -- join the enrolled student's personid to HM and the relationship's relatedpair personid2 to HM to get all possible addresses
				LEFT OUTER JOIN dbo.HouseholdLocation hl WITH (NOLOCK)
					ON hl.householdID = hm.householdID
						AND (hl.startdate is null or hl.startdate <= GETDATE() )
						AND (hl.enddate is null OR hl.endDate >= cast(GETDATE() as date) )
				LEFT OUTER JOIN dbo.address a WITH (NOLOCK)
					on hl.addressid = a.addressid 
		where
			(p.personID= e.personID)
		order by
			1,  -- personid
			2 desc,  -- addressid desc sort so nulls come last
			3,  -- enrolled household members come first before related pairs
			4,   -- HM secondary asc sort so 0's come first
			5,   -- HL secondary asc sort so 0's come first
			6,   -- RP SEQ asc sort - this is a freeform entry field as tinyint with max value = 255 - person notified first should get a 1 and if null then put last ...
			7 desc,   -- HM guardian desc sort so 1 comes before 0
			8 desc,   -- RP guardian desc sort so 1 comes before 0
			9 desc, -- HM mailing desc sort so 1 comes before 0
			10 desc, -- RP mailing desc sort so 1 comes before 0
			11,     -- po box checkbox asc so 0s (no po box) come first
			12 desc  -- number column from address table desc sort so nulls come last
		) 	AddressOrder
	) as TopAddressId

from
	dbo.Enrollment e WITH (NOLOCK)
	INNER JOIN dbo.schoolyear sy with (NOLOCK)
		on sy.endyear = e.endyear and sy.active = 1
	INNER JOIN dbo.Person p WITH (NOLOCK)
		ON p.personID=e.personID
	inner join dbo.calendar c
		on e.calendarID = c.calendarid
	inner join dbo.school sch
		on c.schoolid = sch.schoolid
where
	e.enddate is null and
	e.endyear = 2015 and
	isnull(e.noshow,0) = 0

-- these are sample kids with no households:
--		and e.personid in (
--			968812,
--			292321,
--			964652,
--			961555)

   and p.studentnumber in ('8538049','8503087')

--and sch.number = '0399'
--and p.studentnumber = '8431008'

order by 3
;


