SELECT distinct
	total_served_ytd.school_year as "Year",
    total_served_ytd.students_served as "YTD Served",
    total_served_lytd.students_served as "LYTD Served",
    total_suspended_ytd.students_suspended as "YTD Suspended",
	total_suspended_lytd.students_suspended as "LYTD Suspended",
    round(total_suspended_ytd.students_suspended/total_served_ytd.students_served, 3) as "YTD Susp Rate",
    round(total_suspended_lytd.students_suspended/total_served_lytd.students_served, 3) as "LYTD Susp Rate",
    ytd_attd.attendance_percentage as "YTD Attd Rate",
    lytd_attd.attendance_percentage as "LYTD Attd Rate",
    ytd_abs.absentee_rate as "YTD_Absenteeism",
    lytd_abs.absentee_rate as "LYTD Absenteeism"  
    
FROM
	(SELECT
		count (distinct staa.student_id) as students_served,
		staa.school_year
	FROM
		K12INTEL_DW.FTBL_ENROLLMENTS e
	  	INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on e.student_annual_attribs_key = staa.student_annual_attribs_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES end_sd ON e.school_dates_key_end_enroll = end_sd.school_dates_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = e.school_annual_attribs_key
	  	INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	WHERE
		(e.ENROLLMENT_TYPE  =  'Actual'
		AND reg_sd.rolling_local_school_yr_number = 0
        or reg_sd.local_school_year = '2014-2015'
		and saa.reporting_school_ind = 'Y'
		and e.enrollment_days > 2
        and e.school_key in ('4998', '450', '2314') --4999 Obama/SCTE, 450 Obama, 2314 SCTE
		and extract(month from end_sd.date_value) <> 7)
	GROUP BY
		staa.school_year
	 ) total_served_ytd
   INNER JOIN
	(SELECT
	  actd.local_school_year as school_year,
	  count (distinct staa.student_id) as students_suspended
	FROM
	  K12INTEL_DW.FTBL_DISCIPLINE d
	  INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
	  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on d.student_annual_attribs_key = staa.student_annual_attribs_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = d.school_annual_attribs_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
	  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
	WHERE
		actd.rolling_local_school_yr_number = 0
		and da.DISCIPLINE_ACTION_TYPE_CODE IN ('33', '37', 'OS', 'OSS')
		and saa.reporting_school_ind = 'Y'
        and saa.school_key in ('4998', '450', '2314')
	GROUP BY
		actd.local_school_year
						) total_suspended_ytd  on total_served_ytd.school_year = total_suspended_ytd.school_year
    INNER JOIN
      (SELECT
        count (distinct staa.student_id) as students_served,
        staa.school_year
    FROM
        K12INTEL_DW.FTBL_ENROLLMENTS e
          INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on e.student_annual_attribs_key = staa.student_annual_attribs_key
          INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES reg_sd ON e.school_dates_key_register = reg_sd.school_dates_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES end_sd ON e.school_dates_key_end_enroll = end_sd.school_dates_key
          INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on e.school_key = sch.school_key
          INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_key
          INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = e.school_annual_attribs_key
          INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
    WHERE
        (e.ENROLLMENT_TYPE  =  'Actual'
        AND reg_sd.rolling_local_sch_year_to_date = -1
        and saa.reporting_school_ind = 'Y'
        and e.enrollment_days > 2
        and e.school_key in ('4998', '450', '2314') --4999 Obama/SCTE, 450 Obama, 2314 SCTE
        and extract(month from end_sd.date_value) <> 7)
    GROUP BY
        staa.school_year
     ) total_served_lytd on 1=1
   INNER JOIN
    (SELECT
      actd.local_school_year as school_year,
      count (distinct staa.student_id) as students_suspended
    FROM
      K12INTEL_DW.FTBL_DISCIPLINE d
      INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
      INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS staa on d.student_annual_attribs_key = staa.student_annual_attribs_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS saa on saa.school_annual_attribs_key = d.school_annual_attribs_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS_EXT saax on saa.school_annual_attribs_key = saax.school_annual_attribs_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on sch.school_key = schx.school_key
    WHERE
        actd.rolling_local_sch_year_to_date = -1
        and da.DISCIPLINE_ACTION_TYPE_CODE IN ('33', '37', 'OS', 'OSS')
        and saa.reporting_school_ind = 'Y'
        and saa.school_key in ('4998', '450', '2314')
    GROUP BY
        actd.local_school_year
                        ) total_suspended_lytd  on total_served_lytd.school_year = total_suspended_lytd.school_year
   INNER JOIN   
    (SELECT
        a.local_school_year,
        round( (sum(a.attend_value)   /   sum(a.attend_days) ), 3) as attendance_percentage
    FROM
            k12intel_dw.MPS_MV_ATTEND_YTD_SCHSTUABS  a
    WHERE
           (a.ROLLING_LOCAL_SCH_YEAR_TO_DATE = -1)
           and a.school_key in (4998, 450, 2314)
    group by
        a.local_school_year
       ) lytd_attd  on 1=1
  INNER JOIN  
    (SELECT
        AB.SCHOOL_YEAR,
        round (sum (case when ab.absentee = 'Yes' then 1 else 0 end) / count (distinct ab.student_key) , 3)  absentee_rate
    FROM
        (SELECT
          a.STUDENT_key,
          a.SCHOOL_KEY ,
          a.local_school_year as school_year,
          case when ((sum(a.attend_value)   /   sum(a.attend_days) )  * 100) <= 84 then 'Yes' else 'No' end as absentee
          FROM
                  k12intel_dw.MPS_MV_ATTEND_YTD_SCHSTUABS    a
                  inner join K12INTEL_DW.DTBL_STUDENTS_EVOLVED  se on a.student_evolve_key = se.student_evolve_key
          WHERE
               se.student_current_grade_code not in ('HS', 'K3', 'K4')  -- only use for accountability
               and (a.ROLLING_LOCAL_SCH_YEaR_To_DATE = -1 )
               and A.school_key in (4998, 450, 2314)          -- *** enter each school year to export seperately
        GROUP BY
                  a.STUDENT_key,
                 a.SCHOOL_key,
                 a.local_school_Year
        having sum(a.attend_days) >= 45) ab   --commment this out because not for accountability, for action
    GROUP BY
        ab.school_year
    ) lytd_abs ON 1=1
    INNER JOIN   
    (SELECT
        a.local_school_year,
        round( (sum(a.attend_value)   /   sum(a.attend_days) ), 3) as attendance_percentage
    FROM
            k12intel_dw.MPS_MV_ATTEND_YTD_SCHSTUABS  a
    WHERE
           (a.ROLLING_LOCAL_SCH_YEAR_TO_DATE = 0)
           and a.school_key in (4998, 450, 2314)
    group by
        a.local_school_year
       ) ytd_attd  on 1=1                    
    INNER JOIN
    (SELECT
        AB.SCHOOL_YEAR,
        round (sum (case when ab.absentee = 'Yes' then 1 else 0 end) / count (distinct ab.student_key) , 3)  absentee_rate
    FROM
        (SELECT
          a.STUDENT_key,
          a.SCHOOL_KEY ,
          a.local_school_year as school_year,
          case when ((sum(a.attend_value)   /   sum(a.attend_days) )  * 100) <= 84 then 'Yes' else 'No' end as absentee
          FROM
                  k12intel_dw.MPS_MV_ATTEND_YTD_SCHSTUABS  a
                  inner join K12INTEL_DW.DTBL_STUDENTS_EVOLVED  se on a.student_evolve_key = se.student_evolve_key
          WHERE
               se.student_current_grade_code not in ('HS', 'K3', 'K4')  -- only use for accountability
               and (a.ROLLING_LOCAL_SCH_Year_to_date = 0 )
               and A.school_key in (4998, 450, 2314)          -- *** enter each school year to export seperately
        GROUP BY
                  a.STUDENT_key,
                 a.SCHOOL_key,
                 a.local_school_Year
        having sum(a.attend_days) >= 45) ab   --commment this out because not for accountability, for action
    GROUP BY
        ab.school_year
    ) ytd_abs ON 1=1
     

