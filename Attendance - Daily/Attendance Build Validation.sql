SELECT
    dw.student_id,
    ic.personid,
    dw.date_value,
    dw.school_code,
    dw.school_name,
    dw.attendance_value,
    ic.missed_minutes,
    ic.total_missed_minutes,
    ic.halfdayabsence,
    ic.wholedayabsence,
    case when ic.missed_minutes >= ic.wholedayabsence then 0
        when ic.missed_minutes >= ic.halfdayabsence then .5
        else 1 end as ic_attd_days,
    dw.absence_reason
FROM
    (SELECT
          sd.LOCAL_SCHOOL_YEAR AS SCHOOL_YEAR,
          st.STUDENT_ID,
          cd.day_name_short,
          cd.date_value,
          cd.day_of_month,
          sch.school_code,
          sch.school_name,
          attd.attendance_value,
          attd.absence_reason
    FROM
        k12intel_dw.ftbl_attendance attd
        INNER JOIN k12intel_dw.dtbl_students st on attd.student_key = st.student_key
        INNER JOIN k12intel_dw.dtbl_schools sch ON sch.school_code = st.student_current_school_code
        INNER JOIN k12intel_dw.dtbl_schools_extension sx on sx.school_key = sch.school_key
        INNER JOIN k12intel_dw.dtbl_calendar_dates cd on attd.calendar_date_key  = cd.calendar_date_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = attd.school_dates_key
    WHERE
        sd.local_school_Year = '2014-2015'
    ORDER BY 4,2) dw
    LEFT OUTER JOIN
    (SELECT 
        attd_summary.STAGE_SOURCE,
        attd_summary.CALENDARID,
        attd_summary.PERSONID,
        pr.studentnumber,
        attd_summary.ABSENT_DATE,
        attd_summary.TARDY_CNT,
        attd_summary.EXCUSED_TARDY_CNT,
        attd_summary.EXEMPT_CNT,
        attd_summary.UNEXCUSED_CNT,
        attd_summary.EXCUSED_CNT,
        attd_summary.MISSED_MINUTES,
        attd_summary.TOTAL_MISSED_MINUTES,
        cal.HALFDAYABSENCE,
        cal.WHOLEDAYABSENCE,
        attd_summary.EXCUSE_CNT,
        attd_summary.MIN_EXCUSEID
    FROM 
        (SELECT att.STAGE_SOURCE,
                 att.CALENDARID,
                 att.PERSONID,
                 att."DATE" ABSENT_DATE,
                 SUM (CASE
                         WHEN     att.STAGE_DELETEFLAG = 0
                              AND cal.EXCLUDE <> 1
                              AND per.NONINSTRUCTIONAL = 0
                              AND COALESCE (aex.status,
                                            att.status) = 'T'
                         THEN
                            1
                         ELSE
                            0
                      END)
                    tardy_cnt,
                 SUM (CASE
                         WHEN     att.STAGE_DELETEFLAG = 0
                              AND cal.EXCLUDE <> 1
                              AND per.NONINSTRUCTIONAL = 0
                              AND COALESCE (aex.status,
                                            att.status) = 'T'
                              AND COALESCE (aex.excuse,
                                            att.excuse) = 'E'
                         THEN
                            1
                         ELSE
                            0
                      END)
                    excused_tardy_cnt,
                 SUM (CASE
                         WHEN     att.STAGE_DELETEFLAG = 0
                              AND cal.EXCLUDE <> 1
                              AND per.NONINSTRUCTIONAL = 0
                              AND COALESCE (aex.status,
                                            att.status) NOT IN ('T',
                                                                'E')
                              AND COALESCE (aex.excuse,
                                            att.excuse) = 'X'
                         THEN
                            1
                         ELSE
                            0
                      END)
                    exempt_cnt,
                 SUM (
                    CASE
                       WHEN     att.STAGE_DELETEFLAG = 0
                            AND cal.EXCLUDE <> 1
                            AND per.NONINSTRUCTIONAL = 0
                            AND COALESCE (aex.status,
                                          att.status) NOT IN ('T',
                                                              'E')
                            AND (   COALESCE (aex.excuse,
                                              att.excuse) = 'U'
                                 OR (    att.status = 'A'
                                     AND att.EXCUSEID IS NULL))
                       THEN
                          1
                       ELSE
                          0
                    END)
                    unexcused_cnt,
                 SUM (CASE
                         WHEN     att.STAGE_DELETEFLAG = 0
                              AND cal.EXCLUDE <> 1
                              AND per.NONINSTRUCTIONAL = 0
                              AND COALESCE (aex.status,
                                            att.status) NOT IN ('T',
                                                                'E')
                              AND COALESCE (aex.excuse,
                                            att.excuse) = 'E'
                         THEN
                            1
                         ELSE
                            0
                      END)
                    excused_cnt,
                 SUM (
                    CASE
                       WHEN     att.STAGE_DELETEFLAG = 0
                            AND cal.EXCLUDE <> 1
                            AND per.NONINSTRUCTIONAL = 0
                            AND COALESCE (aex.status,
                                          att.status) NOT IN ('T',
                                                              'E')
                            AND (   COALESCE (aex.excuse,
                                              att.excuse) NOT IN ('X',
                                                                  'P')
                                 OR (    att.status = 'A'
                                     AND att.EXCUSEID IS NULL))
                       THEN
                          NVL (  per.periodMinutes
                               - COALESCE (att.PRESENTMINUTES,
                                           0),
                               0)
                       ELSE
                          0
                    END)
                    missed_minutes,
                 SUM (CASE
                         WHEN     att.STAGE_DELETEFLAG = 0
                              AND cal.EXCLUDE <> 1
                              AND per.NONINSTRUCTIONAL = 0
                              AND COALESCE (aex.status,
                                            att.status) <> 'T'
                         THEN
                            NVL (  per.periodMinutes
                                 - COALESCE (att.PRESENTMINUTES,
                                             0),
                                 0)
                         ELSE
                            0
                      END)
                    total_missed_minutes,
                 COUNT (DISTINCT att.EXCUSEID) EXCUSE_CNT,
                 MIN (att.EXCUSEID) MIN_EXCUSEID
           FROM 
                K12INTEL_STAGING_IC.ATTENDANCE att
                INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal ON att.CALENDARID = cal.CALENDARID
                                                               AND att.STAGE_SOURCE = cal.STAGE_SOURCE
                INNER JOIN K12INTEL_STAGING_IC.PERIOD per  ON att.PERIODID = per.PERIODID AND att.STAGE_SOURCE = per.STAGE_SOURCE
                LEFT JOIN K12INTEL_STAGING_IC.ATTENDANCEEXCUSE aex ON att.EXCUSEID = aex.EXCUSEID
                                                                    AND att.STAGE_SOURCE = aex.STAGE_SOURCE
          WHERE     1 = 1
             --AND cal.EXCLUDE <> 1
             --AND per.NONINSTRUCTIONAL = 0
             --AND att.STAGE_SOURCE = p_PARAM_STAGE_SOURCE
             --netchange processing
             AND EXISTS
                    (SELECT NULL
                       FROM K12INTEL_STAGING_IC.ATTENDANCE att_netchange
                      WHERE     att.STAGE_SOURCE =
                                   att_netchange.STAGE_SOURCE
                            AND att.CALENDARID =
                                   att_netchange.CALENDARID
                            AND att.PERSONID = att_netchange.PERSONID
                            AND att."DATE" = att_netchange."DATE"
    --                                    AND att_netchange.STAGE_MODIFYDATE >=
    --                                           v_NETCHANGE_CUTOFF)
             --AND att.personid in (239046)
             --AND att.DATE = '12/01/2011'
             AND att."DATE" >= TO_DATE ('07/01/2014',
                                        'MM/DD/YYYY'))
            --                     AND att."DATE" <= v_LOCAL_DATA_DATE
             --STAGE_DELETEFLAG filter needs to be commented out
             --AND att.STAGE_DELETEFLAG = 0
             --Filter using K12INTEL_USERDATA.XTBL_BUILD_CONTROL
            --                     AND EXISTS
            --                            (SELECT NULL
            --                               FROM K12INTEL_USERDATA.XTBL_BUILD_CONTROL xbc
            --                              WHERE     xbc.BUILD_NAME = v_SYS_ETL_SOURCE
            --                                    AND    CAST (
            --                                              cal.ENDYEAR - 1 AS VARCHAR2 (10))
            --                                        || '-'
            --                                        || CAST (
            --                                              cal.ENDYEAR AS VARCHAR2 (10)) =
            --                                           xbc.SCOPE_YEAR
            --                                    AND att.STAGE_SOURCE = xbc.SCOPE_SOURCE
            --                                    AND ( (1 =
            --                                              CASE
            --                                                 WHEN xbc.SCOPE_VALUE =
            --                                                         '[ALL]'
            --                                                 THEN
            --                                                    1
            --                                                 ELSE
            --                                                    0
            --                                              END))
            --                                    AND xbc.BUILD_METHOD =
            --                                           CASE
            --                                              WHEN p_PARAM_USE_FULL_REFRESH =
            --                                                      1
            --                                              THEN
            --                                                 'REFRESH'
            --                                              ELSE
            --                                                 'NETCHANGE'
            --                                           END
            --                                    AND xbc.PROCESS_IND = 'Y')
                                             
         GROUP BY att.STAGE_SOURCE,
                           att.CALENDARID,
                           att.PERSONID,
                           att."DATE" ) attd_summary
         INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal ON attd_summary.CALENDARID = cal.CALENDARID
                                                        AND attd_summary.STAGE_SOURCE = cal.STAGE_SOURCE
         INNER JOIN K12INTEL_STAGING_IC.PERSON pr  ON attd_summary.PERSONID = pr.PERSONID
                                                        AND attd_summary.STAGE_SOURCE = pr.STAGE_SOURCE
         INNER JOIN K12INTEL_STAGING_IC.SCHOOL sch   ON cal.SCHOOLID = sch.SCHOOLID
                                                        AND cal.STAGE_SOURCE = sch.STAGE_SOURCE
                                                           AND sch.STAGE_SIS_SCHOOL_YEAR =  2014
         INNER JOIN K12INTEL_STAGING_IC.ENROLLMENT enr ON  attd_summary.PERSONID = enr.PERSONID
                                                           AND attd_summary.CALENDARID = enr.CALENDARID
                                                           AND attd_summary.ABSENT_DATE BETWEEN enr.STARTDATE
                                                                                            AND COALESCE (
                                                                                                   enr.ENDDATE,
                                                                                                   TO_DATE (
                                                                                                      '12/31/9999',
                                                                                                      'MM/DD/YYYY'))
        ) ic on ic.studentnumber = dw.student_id and ic.absent_date = dw.date_value
WHERE 1=1
    and dw.date_value > to_date('09-01-2014', 'MM-DD-YYYY')
--  and dw.student_id = '8595154'
    and dw.attendance_value <> (case when ic.missed_minutes >= ic.wholedayabsence then 0
                                    when ic.missed_minutes >= ic.halfdayabsence then .5
                                    else 1 end)