SELECT distinct
	sd.local_school_year,
--	da.discipline_action_type,
	d.discipline_offense_group,
	d.discipline_offense_category,
	d.discipline_offense_type,
	COUNT (DISTINCT d.discipline_key) AS Referrals,
--	count(da.discipline_action_key) as expulsions
	sum(case when da.DISCIPLINE_ACTION_TYPE_CODE = '43' then 1 else 0 end) as "Expulsion Recommendation",
	sum(case when da.DISCIPLINE_ACTION_TYPE_CODE = '81' then 1 else 0 end) as "Expulsion Dismissed",
	sum(case when da.DISCIPLINE_ACTION_TYPE_CODE = '84' then 1 else 0 end) as "Handle at Local Level",
	sum(case when da.DISCIPLINE_ACTION_TYPE_CODE = '60' then 1 else 0 end) as "Expulsion/No Services",
	sum(case when da.DISCIPLINE_ACTION_TYPE_CODE = '61' then 1 else 0 end) as "Expulsion/Services"
FROM
	K12INTEL_DW.FTBL_DISCIPLINE_actions da
	inner join K12INTEL_DW.FTBL_DISCIPLINE d on da.discipline_key = d.discipline_key
	inner join K12INTEL_DW.DTBL_CALENDAR_DATES  cd on cd.calendar_date_key = da.calendar_date_key
	INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON da.school_dates_key = sd.school_dates_key
WHERE
	cd.month_name_short in ('Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb')
	and sd.local_school_year in ('2012-2013', '2013-2014' )
--	and da.discipline_action_group = 'Expulsion'
	and da.discipline_action_type_code in ('43', '81', '84', '60', '61')
	and( INSTR(da.discipline_action_type, 'Continuing') = 0)
GROUP BY
	sd.local_school_year,
--	da.discipline_action_type
	d.discipline_offense_category,
	d.discipline_offense_group,
	d.discipline_offense_type
ORDER BY
	1
