SELECT
	attend_band.local_school_year,
	attend_band.school_code,
	attend_band.school_name,
	attend_band.attend_band,
	count (distinct student_id) as students,
	round(( sum(attend_band.attend_days)/sum(attend_band.member_days) ),3) as attend_band_rate
FROM
	( SELECT
		ad.local_school_year,
		sch.school_code,
		sch.school_name,
		schx.group2,
		st.student_id,
		sum(ad.attendance_value) as attend_days,
		sum(ad.attendance_days) as member_days,
		round(( sum(ad.ATTENDANCE_VALUE)/sum(ad.ATTENDANCE_DAYS) ),3) as attend_rate,
		case
			when round(( sum(ad.ATTENDANCE_VALUE)/sum(ad.ATTENDANCE_DAYS) ),3) < .6 then 'Less than 60'
			when round(( sum(ad.ATTENDANCE_VALUE)/sum(ad.ATTENDANCE_DAYS) ),3) between .6 and .699 then '60 to 69.9'
			when round(( sum(ad.ATTENDANCE_VALUE)/sum(ad.ATTENDANCE_DAYS) ),3) between .7 and .799 then '70 to 79.9'
			when round(( sum(ad.ATTENDANCE_VALUE)/sum(ad.ATTENDANCE_DAYS) ),3) between .8 and .899 then '80 to 89.9'
			when round(( sum(ad.ATTENDANCE_VALUE)/sum(ad.ATTENDANCE_DAYS) ),3) >= .90 then '90 to 100'
			else 'Unknown'
		end as attend_band
	FROM
	  K12INTEL_DW.FTBL_ATTENDANCE_STUSUMMARY ad
	  INNER JOIN K12INTEL_DW.DTBL_STUDENTS st on st.student_key = ad.student_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = ad.school_key
	 	 INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
	 	 													and schx.group1 in ('01', '02', '03', '04', '05', '06', '07', '08')
	WHERE
		ad.local_school_year = '2013-2014'
	GROUP BY
		ad.local_school_year,
		sch.school_code,
		sch.school_name,
		schx.group2,
		st.student_id  ) attend_band
GROUP BY
	attend_band.local_school_year,
	attend_band.school_code,
	attend_band.school_name,
	attend_band.attend_band
ORDER BY
	2,4
