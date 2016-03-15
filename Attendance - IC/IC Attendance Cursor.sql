SELECT 
        attd_summary.STAGE_SOURCE,
        attd_summary.stage_createdate,
        attd_summary.stage_modifydate,
        cal."NAME",  
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
        attd_summary.MIN_EXCUSEID,
        
        a.code
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
                 MIN (att.EXCUSEID) MIN_EXCUSEID,
                 att.stage_modifydate,
                 att.stage_createdate
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
             AND att.personid = 250670
             AND att."DATE" = to_date('03-30-2015', 'MM-DD-YYYY')
             AND EXISTS(SELECT NULL 
                                FROM K12INTEL_STAGING_IC.ENROLLMENT enr
                                inner join k12intel_Staging_ic.CALENDAR c1
                                on enr.calendarid = c1.calendarid and enr.stage_source = c1.stage_source
                                WHERE att.PERSONID = enr.PERSONID
                                   -- AND att.CALENDARID = enr.CALENDARID
                                    AND enr.STAGE_DELETEFLAG = 0
                                    AND enr.SERVICETYPE = 'P'
                                    AND att."DATE" BETWEEN enr.STARTDATE
                                                    AND COALESCE (
                                                           enr.ENDDATE,
                                                           c1.ENDDATE))
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
                           att."DATE",
                 att.stage_modifydate,
                 att.stage_createdate ) attd_summary
         INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal ON attd_summary.CALENDARID = cal.CALENDARID
                                                        AND attd_summary.STAGE_SOURCE = cal.STAGE_SOURCE
         INNER JOIN K12INTEL_STAGING_IC.ATTENDANCEEXCUSE a ON attd_summary.MIN_EXCUSEID = A.EXCUSEID
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
 ;      