SELECT
    st.student_id,
    st.student_name,
    st.student_current_school_code,
    st.student_current_school,
    ic.value as ic_code,
    ic.name as ic_name,
    st.student_current_grade_code,
    ic.grade as ic_grade
FROM
    K12INTEL_DW.DTBL_STUDENTS st
    INNER JOIN
    (SELECT per.studentnumber,
            id.firstName,
            id.lastName,
            cs.value,
            sch.name,
            enr.grade
    FROM
        K12INTEL_STAGING_IC.Person per 
        LEFT OUTER JOIN K12INTEL_STAGING_IC.Enrollment enr  on per.personID=enr.personID   and enr.startdate <= sysdate and (enr.enddate >= sysdate or enr.enddate is null) and enr.servicetype = 'P' and enr.stateexclude = 0 and enr.stage_deleteflag = 0
        LEFT OUTER JOIN K12INTEL_STAGING_IC.calendar cal  on enr.calendarid = cal.calendarid
        LEFT OUTER JOIN (K12INTEL_STAGING_IC.school sch  
                        INNER JOIN K12INTEL_STAGING_IC.customschool cs on cs.schoolid = sch.schoolid and cs.attributeid = 634)
                        on sch.schoolid = cal.schoolid
        LEFT OUTER JOIN K12INTEL_STAGING_IC.schoolyear sy on sy.endyear = enr.endyear and sy.active = 1
        INNER JOIN K12INTEL_STAGING_IC.Identity id  on id.identityid = per.currentidentityid ) ic on ic.studentnumber = st.student_id
WHERE
  st.student_status = 'Enrolled' 
  and (st.student_current_grade_code != ic.grade 
    or st.student_current_school_code != ic.value)

;
SELECT DISTINCT STUDENT_STATUS FROM K12INTEL_DW.DTBL_STUDENTS