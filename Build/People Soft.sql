select * from k12intel_staging_ppl.ps_job where emplid = '020171'
;
select * from k12intel_staging_ppl.ps_employees where last_name = -- 'Sibila' --128587
'Blazkovec' --020171
;
select * from k12intel_dw.dtbl_staff where staff_employee_id = '128587'
;
select * from k12intel_dw.dtbl_staff_assignments where staff_key = 16272 order by staff_assignment_start_date
;
select distinct
    st.staff_name
    ,st.staff_key    
    ,sch.school_key
    ,sch.SCHOOL_GRADES_GROUP
    ,st.staff_last_name
from
    k12intel_dw.dtbl_course_offerings co
    inner join k12intel_dw.dtbl_staff st on st.staff_key = co.staff_key
    inner join k12intel_dw.dtbl_schools sch on sch.school_key = co.school_key
    inner join k12intel_dw.dtbl_schools_extension se on se.SCHOOL_KEY = sch.school_key
where
    sch.REPORTING_SCHOOL_IND = 'Y'
    and co.course_section_start_date <= (sysdate + 30)
   and co.course_section_end_date >= (sysdate   - 30)
    and st.STAFF_STATUS = 'Active'
    and st.staff_employee_id = '128587'
order by st.STAFF_LAST_NAME
;
select * from k12intel_dw.dtbl_course_offerings co
where co.staff_key = 16272 order by course_section_start_date
;
SELECT
          sec.STAGE_SOURCE
        , sec.SECTIONID
        , sec.TRIALID
        , sec.COURSEID
        , sec."NUMBER"
        , sec.TEACHERDISPLAY
        , sec.MAXSTUDENTS
        , sec.CLASSTYPE
        , sec.SCHEDGROUPID
        , sec.ROOMID
        , sec.LUNCHID
        , sec.LUNCHCOUNT
        , sec.MILKCOUNT
        , sec.ADULTCOUNT
        , sec.SERVICEDISTRICT
        , sec.SERVICESCHOOL
        , sec.MULTIPLETEACHERCODE
        , sec.LOCKBUILD
        , sec.LOCKROSTER
        , sec.GIFTEDDELIVERY
        , sec.GIFTEDCONTENTAREA
        , sec.TEACHERPERSONID
        , sec.PARAPROS
        , sec.SKINNYSEQ
        , sec.LEGACYKEY
        , sec.HIGHLYQUALIFIED
        , sec.HOMEROOMSECTION
        , sec.TEACHINGMETHOD
        , sec.SECTIONGUID
        , sec."LOCK"
        , sec.NONHQTREASON
        , sec.NONHQTEXPLANATION
        , sec.SPEDAREA
        , cal.DISTRICTID
        , cal.SCHOOLID
        , cal.ENDYEAR
        , crs.DEPARTMENTID
        , crs.GRADE
        , crs."NUMBER" COURSE_CODE
        , crs."NAME" COURSE_NAME
        , sch."NUMBER" SCHOOL_CODE
        , dis."NUMBER" DISTRICT_CODE
    FROM K12INTEL_STAGING_IC."SECTION" sec
    INNER JOIN K12INTEL_STAGING_IC.TRIAL t
        ON sec.TRIALID = t.TRIALID
        AND sec.STAGE_SOURCE = t.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.CALENDAR cal
        ON t.CALENDARID = cal.CALENDARID
        AND t.STAGE_SOURCE = cal.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.COURSE crs
        ON sec.COURSEID = crs.COURSEID
        AND sec.stage_source = crs.stage_source
    INNER JOIN K12INTEL_STAGING_IC.SCHOOL sch
        ON cal.SCHOOLID = sch.SCHOOLID
        AND cal.STAGE_SOURCE = sch.STAGE_SOURCE
    INNER JOIN K12INTEL_STAGING_IC.DISTRICT dis
        ON cal.DISTRICTID = dis.DISTRICTID
        AND cal.STAGE_SOURCE = dis.STAGE_SOURCE
    WHERE 1 = 1
        AND sec.STAGE_DELETEFLAG = 0
        AND t.ACTIVE = 1
        AND sch.STAGE_SIS_SCHOOL_YEAR = 2015
        and sec.teacherpersonid = 1044732
        AND sec.STAGE_MODIFYDATE >= SYSDATE - 50
--        AND sec.STAGE_SOURCE = p_PARAM_STAGE_SOURCE;
;
 SELECT  DISTINCT a.STAFF_ASSIGNMENT_KEY
                            , STAFF_KEY
                            , STAFF_ANNUAL_ATTRIBS_KEY
                    FROM K12INTEL_DW.DTBL_STAFF_ASSIGNMENTS a
                    INNER JOIN K12INTEL_KEYMAP.KM_STAFF_ASSN_IC b
                    ON a.STAFF_ASSIGNMENT_KEY = b.STAFF_ASSIGNMENT_KEY
                    WHERE   b.SCHOOLID      = 4
                        AND b.PERSONID      = 1044732
                        AND b.ENDYEAR       = 2016
                        AND b.STAGE_SOURCE  = 'MPS_IC';