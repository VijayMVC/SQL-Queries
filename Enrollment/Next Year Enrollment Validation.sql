SELECT
    st.student_id,
    st.student_activity_indicator,
    st.student_status,
    st.student_current_grade_code,
    cur_enr.grade as ic_cur_grade,
    st.student_current_school_code,
    cur_enr.school_code as ic_cur_school,
    st.student_next_year_grade_code,
    next_enr.grade as ic_next_grade,
    st.student_next_year_school_code,
    next_enr.school_code as ic_next_school
FROM
    K12INTEL_DW.DTBL_STUDENTS st 
    LEFT OUTER JOIN 
    (SELECT enr.* FROM
        (SELECT 
            rank() over (partition by per.personid, enr.endyear order by enr.startdate desc) as r, 
            per.studentnumber,
            enr.enrollmentid,
            cs.value as school_code,
            sch.name as school,
            cal.name as calendar,
            enr.grade,
            enr.startdate,
            enr.enddate,
            enr.endStatus,
            enr.endyear,
            enr.nextCalendar,
            enr.nextgrade 
        FROM
            k12intel_staging_ic.Enrollment enr
            INNER JOIN k12intel_staging_ic.calendar cal  on enr.calendarid = cal.calendarid and enr.stage_deleteflag = 0
            INNER JOIN k12intel_staging_ic.school sch  on sch.schoolid = cal.schoolid and sch.stage_deleteflag = 0
            INNER JOIN k12intel_staging_ic.schoolyear sy  on sy.active = 1 and sy.endyear = enr.endyear
            INNER JOIN k12intel_staging_ic.Person per  on per.personID=enr.personID
            INNER JOIN k12intel_staging_ic.identity id  on id.identityid = per.currentidentityid and id.stage_deleteflag = 0
            INNER JOIN (K12intel_STAGING_IC.CustomSchool CS
                        INNER JOIN K12intel_STAGING_IC.CampusAttribute CA ON CS.AttributeId = CA.AttributeId 
                                                                            AND CS.STAGE_SOURCE= CA.STAGE_SOURCE
                                                                            AND CS.STAGE_DELETEFLAG = 0
                                                                            AND element= 'LOCALSCHOOLNUM' )
                ON CS.SchoolId = SCH.SchoolID
                AND CS.STAGE_SOURCE= SCH.STAGE_SOURCE
                AND CS.STAGE_SIS_SCHOOL_YEAR = SCH.STAGE_SIS_SCHOOL_YEAR 
        WHERE 1=1
             --and per.studentNumber = '8396220'
             and enr.stateexclude <> 1
             and enr.startdate <= sysdate and (enr.enddate is null or enr.enddate >= sysdate)
        ) enr
      WHERE enr.r = 1) cur_enr on cur_enr.studentnumber = st.student_id
    LEFT OUTER JOIN 
    (SELECT enr.* FROM
        (SELECT
            rank() over (partition by per.personid, enr.endyear order by enr.startdate desc) as r, 
            per.studentnumber,
            enr.enrollmentid,
            cs.value as school_code,
            sch.name as school,
            cal.name as calendar,
            enr.grade,
            enr.startdate,
            enr.enddate,
            enr.endStatus,
            enr.endyear,
            enr.nextCalendar,
            enr.nextgrade 
        FROM
            k12intel_staging_ic.Enrollment enr
            INNER JOIN k12intel_staging_ic.calendar cal  on enr.calendarid = cal.calendarid and enr.stage_deleteflag = 0
            INNER JOIN k12intel_staging_ic.school sch  on sch.schoolid = cal.schoolid and sch.stage_deleteflag = 0
            INNER JOIN k12intel_staging_ic.schoolyear sy  on sy.active = 1 and sy.endyear + 1 = enr.endyear
            INNER JOIN k12intel_staging_ic.Person per  on per.personID=enr.personID
            INNER JOIN k12intel_staging_ic.identity id  on id.identityid = per.currentidentityid and id.stage_deleteflag = 0
            INNER JOIN (K12intel_STAGING_IC.CustomSchool CS
                        INNER JOIN K12intel_STAGING_IC.CampusAttribute CA ON CS.AttributeId = CA.AttributeId 
                                                                            AND CS.STAGE_SOURCE= CA.STAGE_SOURCE
                                                                            AND CS.STAGE_DELETEFLAG = 0
                                                                            AND element= 'LOCALSCHOOLNUM' )
                ON CS.SchoolId = SCH.SchoolID
                AND CS.STAGE_SOURCE= SCH.STAGE_SOURCE
                AND CS.STAGE_SIS_SCHOOL_YEAR = SCH.STAGE_SIS_SCHOOL_YEAR 
        WHERE 1=1
             --and per.studentNumber = '8396220'
             and enr.stateexclude <> 1
             and (enr.enddate is null or enr.enddate >= sysdate)
          ) enr
     WHERE enr.r = 1 ) next_enr on next_enr.studentnumber = st.student_id
WHERE
    cur_enr.grade is null
    and next_enr.grade is not null
 
