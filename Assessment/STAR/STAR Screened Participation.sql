SELECT *
FROM
(SELECT enr.student_key, enr.school_key, enr.school_annual_attribs_key, enr.student_annual_attribs_key
, 'Reading' as subject, 'Untested' as test_primary_result, '6' as test_primary_result_code, win.season, win.school_year
,1 - dense_rank() over (partition by win.calendar_type,win.school_year,win.start_date order by win.start_date) rolling_Admin_nbr
FROM
    K12INTEL_DW.FTBL_ENROLLMENTS enr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = enr.school_key
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES bcd on bcd.calendar_date_key = enr.cal_date_key_begin_enroll
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES ecd on ecd.calendar_date_Key = enr.cal_date_key_end_enroll
    INNER JOIN K12INTEL_STAGING_MPSENT.ENT_ENTITY_MASTER_VIEW ent on to_char(ent.esis_id) = sch.school_code
    INNER JOIN K12INTEL_DW.MPSD_STAR_WINDOWS win on win.calendar_type = ent.calendar and substr(win.school_year,1,4) = to_char(ent.school_year_fall)
WHERE 1=1
    and bcd.date_value <= win.end_date - 1
    and ecd.date_value > win.end_date - 1
    AND NOT EXISTS
    (SELECT 1
    FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES tsc
    WHERE tsc.student_key = enr.student_key
        and tsc.season = win.season
        and tsc.school_year = win.school_year
        and tsc.subject = 'Reading'
        and enr.entry_grade_code in ('02', '03', '04', '05', '06', '07', '08', '09', '10', '11')
        and tsc.in_window = 'Yes')
UNION
SELECT enr.student_key, enr.school_key, enr.school_annual_attribs_key, enr.student_annual_attribs_key, 'Mathematics' as subject
, 'Untested' as test_primary_result, '6' as test_primary_result_code, win.season, win.school_year
,1 - dense_rank() over (partition by win.calendar_type,win.school_year,win.start_date order by win.start_date) rolling_Admin_nbr
FROM
    K12INTEL_DW.FTBL_ENROLLMENTS enr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = enr.school_key
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES bcd on bcd.calendar_date_key = enr.cal_date_key_begin_enroll
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES ecd on ecd.calendar_date_Key = enr.cal_date_key_end_enroll
    INNER JOIN K12INTEL_STAGING_MPSENT.ENT_ENTITY_MASTER_VIEW ent on to_char(ent.esis_id) = sch.school_code and ent.school_year_fall = 2014
    INNER JOIN K12INTEL_DW.MPSD_STAR_WINDOWS win on win.calendar_type = ent.calendar and substr(win.school_year,1,4) = to_char(ent.school_year_fall)
WHERE 1=1
    and bcd.date_value <= win.end_date - 1
    and ecd.date_value > win.end_date - 1
    and NOT EXISTS
    (SELECT 1
    FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES tsc
    WHERE tsc.student_key = enr.student_key
        and tsc.season = win.season
        and tsc.school_year = win.school_year
        and tsc.subject = 'Mathematics'
        and enr.entry_grade_code in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11')
        and tsc.in_window = 'Yes')
UNION
SELECT enr.student_key, enr.school_key, enr.school_annual_attribs_key, enr.student_annual_attribs_key, 'Early Literacy' as subject
, 'Untested' as test_primary_result, '6' as test_primary_result_code, win.season, win.school_year
,1 - dense_rank() over (partition by win.calendar_type,win.school_year,win.start_date order by win.start_date) rolling_Admin_nbr
FROM
    K12INTEL_DW.FTBL_ENROLLMENTS enr
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = enr.school_key
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES bcd on bcd.calendar_date_key = enr.cal_date_key_begin_enroll
    INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES ecd on ecd.calendar_date_Key = enr.cal_date_key_end_enroll
    INNER JOIN K12INTEL_STAGING_MPSENT.ENT_ENTITY_MASTER_VIEW ent on to_char(ent.esis_id) = sch.school_code and ent.school_year_fall = 2014
    INNER JOIN K12INTEL_DW.MPSD_STAR_WINDOWS win on win.calendar_type = ent.calendar and substr(win.school_year,1,4) = to_char(ent.school_year_fall)
WHERE 1=1
    and bcd.date_value <= win.end_date - 1
    and ecd.date_value > win.end_date - 1
    and enr.entry_grade_code in ('K5', '01')
    and NOT EXISTS
    (SELECT 1
    FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES tsc
    WHERE tsc.student_key = enr.student_key
        and tsc.season = win.season
        and tsc.school_year = win.school_year
        and tsc.subject = 'Early Literacy'
        and tsc.in_window = 'Yes')
UNION
SELECT student_key, school_key, sc.school_annual_attribs_key, sc.student_annual_attribs_key, subject, test_primary_result
, test_primary_result_code, season, school_year ,rolling_admin_nbr
FROM k12intel_dw.mps_mv_star_component_scores sc
) part
INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS ON dtbl_student_annual_attribs.student_annual_attribs_key = part.student_annual_attribs_key
INNER JOIN K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS on dtbl_school_annual_attribs.school_annual_attribs_key = part.school_annual_attribs_key
INNER JOIN K12INTEL_DW.DTBL_SCHOOLS on dtbl_schools.school_key = part.school_key
WHERE
    part.rolling_admin_nbr  between -5 and 0
order by 1
--    and tsc.student_annual_attribs_key = 0
--    AND WIN.SEASON IS NULL
--)
;