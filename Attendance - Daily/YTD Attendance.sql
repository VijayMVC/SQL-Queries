SELECT
	year0.school_code,
	year0.school_name as school,
	year0.group2 as Region,
	year0.ytd_date,
	year0.local_school_year as year_1,
	year0.attend_days as year_1_attend_days,
	year0.member_days as year_1_member_days,
	year0.attend_rate as year_1_attend_rate,
	year1.local_school_year as year_2,
	year1.attend_days as year_2_attend_days,
	year1.member_days as year_2_member_days,
	year1.attend_rate as year_2_attend_rate,
    year2.local_school_year as year_3,
	year2.attend_days as year_3_attend_days,
	year2.member_days as year_3_member_days,
	year2.attend_rate as year_3_attend_rate
FROM
	(SELECT
			 sx.school_code,
			 sx.school_name,
			 sx.group2,
			 ma.local_school_year,
			 asofdate as ytd_date,
		     sum (attend_value) as attend_days,
		     sum (attend_days) as member_days,
		     round (sum (attend_value) / sum(attend_days), 3) as attend_rate
		FROM
			K12INTEL_DW.MPS_MV_ATTEND_YTD_SCH ma
			INNER JOIN
			K12INTEL_DW.DTBL_SCHOOLS_EXTENSION sx
			ON ma.school_code = sx.school_code
		WHERE
			ma.rolling_local_sch_year_to_date = 0
		GROUP BY
			sx.group2,
			ma.local_school_year,
		 	sx.school_code,
			 sx.school_name,
			 asofdate )  year0
	INNER JOIN
			(SELECT
			 sx.school_code,
			 sx.school_name,
			 sx.group2,
			 ma.local_school_year,
			 asofdate as ytd_date,
		     sum (attend_value) as attend_days,
		     sum (attend_days) as member_days,
		     round (sum (attend_value) / sum(attend_days), 3) as attend_rate
		FROM
			K12INTEL_DW.MPS_MV_ATTEND_YTD_SCH ma
			INNER JOIN
			K12INTEL_DW.DTBL_SCHOOLS_EXTENSION sx
			ON ma.school_code = sx.school_code
		WHERE
			ma.rolling_local_sch_year_to_date = -1
		GROUP BY
			sx.group2,
			ma.local_school_year,
		 	sx.school_code,
			 sx.school_name,
			 asofdate )  year1 ON year0.school_code = year1.school_code
	INNER JOIN
		(SELECT
			 sx.school_code,
			 sx.school_name,
			 sx.group2,
			 ma.local_school_year,
			 asofdate as ytd_date,
		     sum (attend_value) as attend_days,
		     sum (attend_days) as member_days,
		     round (sum (attend_value) / sum(attend_days), 3) as attend_rate
		FROM
			K12INTEL_DW.MPS_MV_ATTEND_YTD_SCH ma
			INNER JOIN
			K12INTEL_DW.DTBL_SCHOOLS_EXTENSION sx
			ON ma.school_code = sx.school_code
		WHERE
			ma.rolling_local_sch_year_to_date = -2
		GROUP BY
			sx.group2,
			ma.local_school_year,
		 	sx.school_code,
			 sx.school_name,
			 asofdate )   year2 ON year2.school_code = year0.school_code
