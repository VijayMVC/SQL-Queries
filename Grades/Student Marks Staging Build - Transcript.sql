SELECT
    tcrs.STAGE_SOURCE
        , tcrs.TRANSCRIPTID
        , tcrs.PERSONID
        , tcrs.COURSENUMBER
        , tcrs.STATECODE
        , tcrs.COURSENAME
        , tcrs.STANDARDNUMBER
        , tcrs.STANDARDNAME
        , tcrs.DISTRICTNUMBER
        , tcrs.SCHOOLNUMBER
        , tcrs.SCHOOLNAME
        , tcrs.STATUS
        , tcrs."DATE"
        , tcrs.STARTYEAR
        , tcrs.ENDYEAR
        , tcrs.GRADE
        , tcrs.SCORE
        , tcrs."PERCENT"
        , tcrs.GPAWEIGHT
        , tcrs.GPAVALUE
        , tcrs.BONUSPOINTS
        , tcrs.GPAMAX
        , tcrs.SCOREID
        , tcrs.STARTTERM
        , tcrs.ENDTERM
        , tcrs.TERMSLONG
        , tcrs.ACTUALTERM
        , tcrs.COMMENTS
        , tcrs."EXEMPT"
        , tcrs.VOCATIONALCODE
        , tcrs.DISTANCECODE
        , tcrs.HONORSCODE
        , tcrs.ACTIVITYCODE
        , tcrs.TECHNOLOGY
        , tcrs.GIFTEDDELIVERY
        , tcrs.GIFTEDCONTENTAREA
        , tcrs.TEACHERNUMBER
        , tcrs.UNWEIGHTEDGPAVALUE
        , tcrs.COURSEPART
        , tcrs.SPECIALEDCODE
        , tcrs.LEGACYKEY
        , tcrs.COURSETYPE
        , tcrs.DISTRICTID
        , tcrs.MODIFIEDDATE
        , tcrs.MODIFIEDBYID
        , tcrs.REPEATCOURSE
        , tcrs.COLLEGECODE
        , tcrs.CALENDARTERMS
        , tcrs.SPECIALCODE
        , tcrs.TERMSTARTDATE
        , tcrs.TERMENDDATE
        , tcrs.ABBREVIATION
        , tcrs.SPECIALGPA
        , tcrs.GRADINGTASKCODE
        , tcrs.CALENDARTYPE
        , tcrs.ALTSTATECODE
        , tcrs.SUMMERSCHOOL
        , tcrs.TRANSCRIPTFIELD1
        , tcrs.TRANSCRIPTFIELD2
        , tcrs.TRANSCRIPTFIELD3
        , tcrs.TRANSCRIPTFIELD4
        , tcrs.TRANSCRIPTFIELD5
        , tcrs.TEACHERPERSONID
        , tcrs.NCESGRADE
        , tcrs.SECONDARYCREDIT
        , tcd.CREDITID
        , tcd.STANDARDID
        , tcd.CREDITSEARNED
        , tcd.CREDITSATTEMPTED
        , tcd.CREDITCODE    
        , gs.SECTIONID
        , per.STUDENTNUMBER
        , dis."NUMBER" DISTRICT_CODE
        , curr.SCOREGROUPID
    FROM K12INTEL_STAGING_IC.TRANSCRIPTCOURSE tcrs
    INNER JOIN K12INTEL_STAGING_IC.TRANSCRIPTCREDIT tcd
        ON tcrs.TRANSCRIPTID = tcd.TRANSCRIPTID AND tcrs.STAGE_SOURCE = tcd.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.PERSON per
        ON tcrs.PERSONID = per.PERSONID AND tcrs.STAGE_SOURCE = per.STAGE_SOURCE
    LEFT JOIN K12INTEL_STAGING_IC.GRADINGSCORE gs
        ON tcrs.SCOREID = gs.SCOREID AND tcrs.STAGE_SOURCE = gs.STAGE_SOURCE
    --LEFT JOIN K12INTEL_STAGING_IC.SECTION sec with(nolock)
    --ON gs.SECTIONID = sec.SECTIONID AND gs.STAGE_SOURCE = sec.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.DISTRICT dis
        ON tcrs.DISTRICTID = dis.DISTRICTID AND tcrs.STAGE_SOURCE = dis.STAGE_SOURCE
    LEFT JOIN K12INTEL_STAGING_IC.CurriculumStandard curr
        on tcd.standardID = curr.standardID AND tcd.STAGE_SOURCE = curr.STAGE_SOURCE
    WHERE 1=1
        AND tcrs.STARTYEAR >= 2008
        and per.studentnumber = '8617255'
        -- JLH TEMP Added to filter out marks imported from esis
        AND (tcrs.comments not like '%eSIS_Credits_ID%' OR TCRS.COMMENTS IS NULL)