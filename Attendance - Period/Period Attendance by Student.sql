SELECT 
    --k12intel_dw.mpsf_period_attendance_seq.NEXTVAL AS period_attendance_key,
    v.student_key,
    --    dst.student_id, --FOR TESTING PURPOSES
    v.school_key,
    v.school_dates_key,
    v.calendar_dates_key,
    v.course_key,
    v.course_offerings_key,
    se.student_evolve_key,
    v.student_annual_attribs_key,
    v.school_annual_attribs_key,
    v.staff_key,
    v.staff_assignment_key,
    v.student_class_minutes,
    v.course_period,
    v.local_day_cycle,
    v.course_section_name,
    NVL (pa.attendance_type, 'Present') AS attendance_type,
    NVL (pa.excused_absence, '--') AS excused_absence,
    NVL (pa.absence_reason_code, '--') AS absence_reason_code,
    NVL (pa.absence_reason, '--') AS absence_reason,
    CASE
     WHEN (   NVL (pa.attendance_type, 'Present') IN ('Present',
                                                      'Late')
           OR NVL (pa.excused_absence, '--') IN ('Authorized',
                                                 'Exempt'))
     THEN
        1
     WHEN NVL (pa.absence_reason_code, '--') IN ('TAUN',
                                                 'TAEX')
     THEN
        1
     ELSE
        0
    END
     AS attendance_value,
    v.date_value,
    SYSDATE AS create_date --REPLACE VARIABLE v_create_date
FROM 
    (SELECT 
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
                    and cs.stage_deleteflag = 0
                JOIN k12intel_dw.dtbl_school_dates sd  ON  sd.date_value = d."DATE"
                    AND sd.school_code =  cs."VALUE" 
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
--        AND ss.school_key = 875
        and co.course_period = '01'
        AND sd.date_value < sysdate
        AND sd.date_value >= ss.schedule_start_date
        AND sd.date_value < ss.schedule_end_date
        AND (upper(sd.local_day_cycle) = upper(co.course_section_days)
            OR (co.course_section_days = 'A,B' and sd.local_day_cycle in ('A DAY', 'B DAY'))
            OR (co.course_section_days = 'A,C' and sd.local_day_cycle in ('A DAY', 'C DAY'))
            OR (co.course_section_days = 'B,D' and sd.local_day_cycle in ('B DAY', 'D DAY'))
            OR (co.course_section_days = 'A,B,C,D' and sd.local_day_cycle in ('A DAY', 'B DAY','C DAY', 'D DAY')))
        ) v
    LEFT JOIN k12intel_dw.ftbl_period_absences pa  ON pa.school_dates_key = v.school_dates_key
                        AND pa.student_key = v.student_key
                        AND pa.course_offerings_key =  v.course_offerings_key
    INNER JOIN k12intel_dw.dtbl_students dst ON dst.student_key = v.student_key
    INNER JOIN k12intel_dw.dtbl_students_evolved se ON se.student_key = v.student_key
        AND se.sys_begin_date <= v.date_value
        AND se.sys_end_date > v.date_value
    WHERE 1 = 1 AND v.school_key = 875 
--        AND dst.student_id = '8471400'
                              
;
select * from k12intel_dw.dtbl_schools where school_code = '474'
;
select * from k12intel_dw.dtbl_school_dates where school_key = 875 and local_school_year = '2015-2016'
;
select * from k12intel_dw.dtbl_course_offerings where school_key = 875 and course_section_end_date >= to_date('09-01-2015', 'MM-DD-YYYY')