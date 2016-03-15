SELECT attd_summary.STAGE_SOURCE,
        per.studentnumber,
        --     attd_summary.CALENDARID,
             attd_summary.PERSONID,
             attd_summary.ABSENT_DATE,
             --per.STUDENTNUMBER,
             --sch."NUMBER" SCHOOL_CODE,
             attd_summary.TARDY_CNT,
             attd_summary.EXCUSED_TARDY_CNT,
             attd_summary.EXEMPT_CNT,
             attd_summary.UNEXCUSED_CNT,
             attd_summary.EXCUSED_CNT,
             attd_summary.MISSED_MINUTES,
             attd_summary.TOTAL_MISSED_MINUTES,
             attd_summary.HALFDAYABSENCE,
             attd_summary.WHOLEDAYABSENCE,
             attd_summary.EXCUSE_CNT,
             attd_summary.MIN_EXCUSEID--,
             --enr.ENROLLMENTID
FROM (SELECT att.STAGE_SOURCE,
        -- att.CALENDARID,
         att.PERSONID,
         att."DATE" ABSENT_DATE,
         MAX(cal.HALFDAYABSENCE) HALFDAYABSENCE,
         MAX(cal.WHOLEDAYABSENCE) WHOLEDAYABSENCE,
         SUM (CASE
                 WHEN     att.STAGE_DELETEFLAG = 0
                      AND cal.EXCLUDE <> 1
                      AND per.NONINSTRUCTIONAL = 0
                      AND COALESCE (aex.status, att.status) = 'T'
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
                      AND COALESCE (aex.status, att.status) = 'T'
                      AND COALESCE (aex.excuse, att.excuse) = 'E'
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
                      AND ((COALESCE (aex.status, att.status) NOT IN ('T', 'E') AND
                          COALESCE (aex.excuse, att.excuse) = 'X') OR
                          COALESCE (aex.status, att.status) = 'P') 
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
                    AND COALESCE (aex.status,att.status) NOT IN ('T','E','P')
                    AND (   COALESCE (aex.excuse,att.excuse) = 'U'
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
                      AND COALESCE (aex.status,att.status) NOT IN ('T','E','P')
                      AND COALESCE (aex.excuse,att.excuse) = 'E'
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
                    AND COALESCE (aex.status,att.status) NOT IN ('T','E','P')
                    AND (   COALESCE (aex.excuse,att.excuse) NOT IN ('X','P')
                         OR (    att.status = 'A'
                             AND att.EXCUSEID IS NULL))
               THEN
                  NVL (  per.periodMinutes
                       - COALESCE (att.PRESENTMINUTES,0),
                       0)
               ELSE
                  0
            END)
            missed_minutes,
         SUM (CASE
                 WHEN     att.STAGE_DELETEFLAG = 0
                      AND cal.EXCLUDE <> 1
                      AND per.NONINSTRUCTIONAL = 0
                      AND COALESCE (aex.status,att.status) <> 'T'
                 THEN
                    NVL (  per.periodMinutes - COALESCE (att.PRESENTMINUTES,0),0)
                 ELSE
                    0
              END)
            total_missed_minutes,
         COUNT (DISTINCT att.EXCUSEID) EXCUSE_CNT,
         MIN (att.EXCUSEID) MIN_EXCUSEID
    FROM K12INTEL_STAGING_IC.ATTENDANCE att
         INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal
            ON     att.CALENDARID = cal.CALENDARID
               AND att.STAGE_SOURCE = cal.STAGE_SOURCE
         INNER JOIN K12INTEL_STAGING_IC.PERIOD per
            ON     att.PERIODID = per.PERIODID
               AND att.STAGE_SOURCE = per.STAGE_SOURCE
         LEFT JOIN K12INTEL_STAGING_IC.ATTENDANCEEXCUSE aex
            ON     att.EXCUSEID = aex.EXCUSEID
               AND att.STAGE_SOURCE = aex.STAGE_SOURCE                  
      WHERE     1 = 1
                     --AND cal.EXCLUDE <> 1
                     --AND per.NONINSTRUCTIONAL = 0
--                     AND att.STAGE_SOURCE = p_PARAM_STAGE_SOURCE
                     --netchange processing
--                     AND EXISTS
--                            (SELECT NULL
--                               FROM K12INTEL_STAGING_IC.ATTENDANCE att_netchange
--                              WHERE     att.STAGE_SOURCE =
--                                           att_netchange.STAGE_SOURCE
--                                    AND att.CALENDARID =
--                                           att_netchange.CALENDARID
--                                    AND att.PERSONID = att_netchange.PERSONID
--                                    AND att."DATE" = att_netchange."DATE"
--                                    AND (   att_netchange.STAGE_MODIFYDATE >= v_NETCHANGE_CUTOFF
--                                            OR att."DATE" >= v_NETCHANGE_CUTOFF
                                         --stage modify date will handle this case and prevent records from getting over processed
                                         --OR att_netchange.STAGE_DELETEFLAG = 1 --S.Schnelz 03-06-2015 Added OR STAGE_DELETEFLAG
--                                         )
--                             )
                     --AND att.personid in (239046)
                     --AND att.DATE = '12/01/2011'
                     --JJM 3/30/2015 Only process record if there is a valid Primary enrollment during the absent date
                     AND EXISTS(SELECT NULL 
                                FROM K12INTEL_STAGING_IC.ENROLLMENT enr
                                inner join k12intel_Staging_ic.CALENDAR c1
                                on enr.calendarid = c1.calendarid and enr.stage_source = c1.stage_source
                                WHERE att.PERSONID = enr.PERSONID
                                    AND att.STAGE_SOURCE = enr.STAGE_SOURCE
                                    AND att.CALENDARID = enr.CALENDARID
                                    AND enr.STAGE_DELETEFLAG = 0
                                    AND enr.SERVICETYPE = 'P'
                                    AND att."DATE" BETWEEN enr.STARTDATE
                                                    AND COALESCE (
                                                           enr.ENDDATE,
                                                           c1.ENDDATE))
                     AND att."DATE" >= TO_DATE ('07/01/2012', 'MM/DD/YYYY')
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
                     --  att.CALENDARID,
                       att.PERSONID,
                       att."DATE") attd_summary
             INNER JOIN K12INTEL_STAGING_IC.PERSON per
                ON     attd_summary.PERSONID = per.PERSONID
                   AND attd_summary.STAGE_SOURCE = per.STAGE_SOURCE
             /*INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal
                ON     attd_summary.CALENDARID = cal.CALENDARID
                   AND attd_summary.STAGE_SOURCE = cal.STAGE_SOURCE
             
             INNER JOIN K12INTEL_STAGING_IC.SCHOOL sch
                ON     cal.SCHOOLID = sch.SCHOOLID
                   AND cal.STAGE_SOURCE = sch.STAGE_SOURCE
                   AND sch.STAGE_SIS_SCHOOL_YEAR =
                          v_LOCAL_CURRENT_SCHOOL_YEAR
             --JJM 3/30/2015 Changed to left join, move delete flag to join on clause
             LEFT JOIN K12INTEL_STAGING_IC.ENROLLMENT enr
                ON     attd_summary.PERSONID = enr.PERSONID
                   AND attd_summary.CALENDARID = enr.CALENDARID
                   AND enr.STAGE_DELETEFLAG = 0 
                   AND attd_summary.ABSENT_DATE BETWEEN enr.STARTDATE
                                                    AND COALESCE (
                                                           enr.ENDDATE,
                                                           TO_DATE (
                                                              '12/31/9999',
                                                              'MM/DD/YYYY'))*/
                   
WHERE
   per.studentnumber = '8299155'