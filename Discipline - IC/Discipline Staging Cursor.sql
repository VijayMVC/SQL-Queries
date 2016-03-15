SELECT STAGE_SOURCE,
             EVENTID,
             CALENDARID,
             OFFENSE_NAME,
             OFFENSE_CODE,
             WEAPONCODE,
             VIOLENCEINDICATOR,
             STAFFNAME,
             REFERRALNAME,
             OFFENSE_COMMENTS,
             STATEEVENTCODE,
             INCIDENTID,
             OFFENSE_TYPEID,
             ROLEID,
             PERSONID,
             ROLE,
             ROLE_COMMENTS,
             STUDENTNUMBER,
             ENDYEAR,
             RESOLUTIONID,
             DISCASSIGNDATE,
             ACTION_DATE,
             ACTION_CODE,
             ACTION_NAME,
             REMOVALREASON,
             ENDDATE,
             ACTION_COMMENTS,
             SCHOOLDAYSDURATION,
             RETURNDATE,
             STATERESCODE,
             ADMINPERSONID,
             ENDTIMESTAMP,
             ACTION_TYPEID,
             SCHOOL_CODE,
             DISTRICT_CODE,
             DESCRIPTION,
             LOCATION,
             OFFENSE_DATE,
             REFERRALPERSONID,
             stage_modifydate_one,
             stage_modifydate_two,
             stage_modifydate_three,
             stage_modifydate_four
        FROM (SELECT a.STAGE_SOURCE,
        a.stage_modifydate as stage_modifydate_one,
                             a.EVENTID,
                     a.CALENDARID,
                     a."NAME", --  "OFFENSE_NAME",
                     a.CODE, -- "OFFENSE_CODE",
                     a.WEAPONCODE,
                     a.VIOLENCEINDICATOR,
                     a.STAFFNAME,
                     a.REFERRALNAME,
                     a.COMMENTS "OFFENSE_COMMENTS",
                     a.STATEEVENTCODE,
                     a.INCIDENTID,
                     a.TYPEID OFFENSE_TYPEID,
                     b.ROLEID,
                     b.stage_modifydate as stage_modifydate_two,
                     b.PERSONID,
                     b."ROLE",
                     b.COMMENTS "ROLE_COMMENTS",
                     bt.code "OFFENSE_CODE",
                     bt.name "OFFENSE_NAME",
                     c.STUDENTNUMBER,
                     d.ENDYEAR,
                     d.SCHOOLID,
                     e.RESOLUTIONID,
                     e.DISCASSIGNDATE,
                     e.stage_modifydate as stage_modifydate_three,
                     e."TIMESTAMP" "ACTION_DATE",
                     e.CODE "ACTION_CODE",
                     e."NAME" "ACTION_NAME",
                     e.REMOVALREASON,
                     e.ENDDATE,
                     e.COMMENTS "ACTION_COMMENTS",
                     e.SCHOOLDAYSDURATION,
                     e.RETURNDATE,
                     e.STATERESCODE,
                     e.ADMINPERSONID,
                     e.ENDTIMESTAMP,
                     e.TYPEID ACTION_TYPEID,
                     g."NUMBER" "SCHOOL_CODE",
                     h."NUMBER" "DISTRICT_CODE",
                     i.DESCRIPTION,
                     i.LOCATION,
                     i."TIMESTAMP" "OFFENSE_DATE",
                     i.REFERRALPERSONID,
                     i.stage_modifydate as stage_modifydate_four,
                     ROW_NUMBER ()
                     OVER (
                        PARTITION BY a.STAGE_SOURCE, a.EVENTID, b.PERSONID
                        ORDER BY
                           CASE
                              WHEN e.RESOLUTIONID IS NOT NULL THEN 0
                              ELSE 1
                           END,
                           f.domain_sort,
                           e."TIMESTAMP" DESC,
                           e.resolutionid DESC,
                           b.roleid DESC)
                        r
                FROM K12INTEL_STAGING_IC.BEHAVIOREVENT a
                     INNER JOIN K12INTEL_STAGING_IC.BEHAVIORTYPE bt
                        ON     a.typeID = bt.typeID
                     INNER JOIN K12INTEL_STAGING_IC.BEHAVIORROLE b
                        ON     a.EVENTID = b.EVENTID
                           AND a.STAGE_SOURCE = b.STAGE_SOURCE
                           AND b.STAGE_DELETEFLAG = 0
                     INNER JOIN K12INTEL_STAGING_IC.PERSON c
                        ON     b.PERSONID = c.PERSONID
                           AND b.STAGE_SOURCE = c.STAGE_SOURCE
                     LEFT JOIN K12INTEL_STAGING_IC.BEHAVIORRESOLUTION e
                        ON     b.ROLEID = e.ROLEID
                           AND b.STAGE_SOURCE = e.STAGE_SOURCE
                           AND e.STAGE_DELETEFLAG = 0
                     LEFT JOIN K12INTEL_USERDATA.XTBL_DOMAIN_DECODES f
                        ON     e.CODE = f.DOMAIN_CODE
                           AND f.DOMAIN_NAME = 'DISCIPLINE_ACTION_SEVERITY'
                           AND f.DOMAIN_SCOPE = e.STAGE_SOURCE
                     INNER JOIN K12INTEL_STAGING_IC.BEHAVIORINCIDENT i
                        ON     a.INCIDENTID = i.INCIDENTID
                           AND a.STAGE_SOURCE = i.STAGE_SOURCE
                           AND i.STAGE_DELETEFLAG = 0
                     INNER JOIN K12INTEL_STAGING_IC.CALENDAR d
                        ON     i.CALENDARID = d.CALENDARID
                           AND i.STAGE_SOURCE = d.STAGE_SOURCE
                     INNER JOIN K12INTEL_STAGING_IC.SCHOOL g
                        ON     d.SCHOOLID = g.SCHOOLID
                           AND d.STAGE_SOURCE = g.STAGE_SOURCE
                           AND g.STAGE_SIS_SCHOOL_YEAR =
                                  2015
                     INNER JOIN K12INTEL_STAGING_IC.DISTRICT h
                        ON     d.DISTRICTID = h.DISTRICTID
                           AND d.STAGE_SOURCE = g.STAGE_SOURCE
               WHERE   1=1  -- and b.role IN ('Offender', 'Participant') --Added in Partcipant on Fam Serv request 3/13/15 BW
                     --and a."TIMESTAMP" IS NOT NULL
                     AND d.ENDYEAR >= 2013
                     AND a.STAGE_SOURCE = 'MPS_IC'
                     AND a.STAGE_DELETEFLAG = 0
                     and b.personid = 360554
                     --and b.eventid = 1809409
                     AND i.STATUS <> 'DF'
--                     AND (   a.STAGE_MODIFYDATE >= 
--                          OR 
--                         
--                              b.STAGE_MODIFYDATE >= v_NETCHANGE_CUTOFF
--                          OR (    e.RESOLUTIONID IS NOT NULL
--                              AND e.STAGE_MODIFYDATE >= v_NETCHANGE_CUTOFF)
--                          OR i.STAGE_MODIFYDATE >= v_NETCHANGE_CUTOFF)
                    ) b
       WHERE b.r = 1