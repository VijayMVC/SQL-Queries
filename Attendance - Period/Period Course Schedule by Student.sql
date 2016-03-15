SELECT 
    sd.date_value,
    sd.school_dates_key,
    sd.calendar_dates_key,
    sd.local_day_cycle,
    sd.school_key,
    co.course_section_days,
    co.course_section_name,
    co.course_offerings_key
     AS course_offerings_key,
    ss.student_class_minutes,
    co.course_key,
    co.staff_key,
    co.staff_assignment_key,
    co.course_period,
    ss.student_key,
    -- se.student_evolve_key,
    ss.student_annual_attribs_key,
    ss.school_annual_attribs_key
    --BW: REWROTE JOINS
FROM 
    k12intel_dw.ftbl_student_schedules ss
    INNER JOIN  k12intel_dw.dtbl_course_offerings co ON ss.course_offerings_key = co.course_offerings_key
    INNER JOIN k12intel_dw.dtbl_schools ds ON   ds.school_key = ss.school_key
             AND co.school_key = ds.school_key
    INNER JOIN
      (SELECT 
            d."DATE" AS DATE_VALUE,
            d.calendarid,
            ps.name AS local_day_cycle,
            c.name,
            c.schoolid,
            s."NUMBER",
            sd.school_code,
            sd.local_enroll_Day,
            sd.local_school_year,
            sd.calendar_dates_key,
            sd.school_Dates_key,
            sd.school_key
        FROM 
            k12intel_staging_ic.day d
            JOIN k12intel_staging_ic.periodschedule ps  ON d.periodScheduleID = ps.periodScheduleID
            JOIN k12intel_staging_ic.calendar c ON c.calendarid = d.calendarid
            JOIN k12intel_staging_ic.school s  ON  s.schoolid = c.schoolid
                AND s.STAGE_SIS_SCHOOL_YEAR = 2015 and S.STAGE_DELETEFLAG = 0
            JOIN K12intel_STAGING_IC.CustomSchool cs  ON     cs.schoolid = s.schoolid
                AND cs.attributeid = 634
                AND cs.STAGE_SIS_SCHOOL_YEAR = 2015
            JOIN k12intel_dw.dtbl_school_dates sd  ON  sd.date_value = d."DATE"
                AND sd.school_code =  cs."VALUE" and cs.stage_deleteflag = 0
        WHERE 1=1
            and not exists
            (SELECT 1
            FROM
                k12intel_staging_ic.day d1
                JOIN k12intel_staging_ic.periodschedule ps1  ON d1.periodScheduleID = ps1.periodScheduleID
                JOIN k12intel_staging_ic.period p1 on p1.periodscheduleid = ps1.periodscheduleid
                JOIN k12intel_staging_ic.calendar c1 ON c1.calendarid = d1.calendarid
            WHERE
                p1.name in ('AM', 'PM')
                and c1.calendarid = c.calendarid)  
                ) sd
     ON ds.school_key = sd.school_key
WHERE     1 = 1
    AND sd.local_school_year = '2015-2016'
    AND sd.local_enroll_day = 1
    and co.course_period = '01'
    AND ss.school_key = 437
    AND sd.date_value < sysdate
    AND sd.date_value >= ss.schedule_start_date
    AND sd.date_value < ss.schedule_end_date
    AND (sd.local_day_cycle = co.course_section_days
            OR (co.course_section_days = 'A,B' and sd.local_day_cycle in ('A DAY', 'B DAY'))
            OR (co.course_section_days = 'A,C' and sd.local_day_cycle in ('A DAY', 'C DAY'))
            OR (co.course_section_days = 'B,D' and sd.local_day_cycle in ('B DAY', 'D DAY'))
            OR (co.course_section_days = 'A,B,C,D' and sd.local_day_cycle in ('A DAY', 'B DAY','C DAY', 'D DAY')))
--    and sd.date_value = to_date('08-05-2015', 'MM-DD-YYYY')
--    and ss.student_key = 112508
ORDER BY 1,7
;
select student_key from k12intel_dw.dtbl_students where student_id = '8501365'
;
select school_key from k12intel_dw.dtbl_schools where school_code = '176'