SELECT
    sch.school_code as "School Code"
    ,sch.school_name as "Name"
    ,enr.students as "Total Students Served"
    ,count(distinct susp.student_key) as "Suspended Students"
    ,round(count(distinct susp.student_key)/enr.students,3) as "Suspension Rate"
    ,count(distinct intv.student_key) as "Suspended w/Intervention"
    ,round(count(distinct intv.student_key)/nullif(count(distinct susp.student_key),0),3) as "Pct Suspended w/Intervention"
FROM
    K12INTEL_DW.DTBL_SCHOOLS sch
    INNER JOIN
    (SELECT
        count (distinct enr.student_key) as students
        ,enr.school_key
    FROM
        K12INTEL_DW.FTBL_ENROLLMENTS enr
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on enr.SCHOOL_DATES_KEY_BEGIN_ENROLL = sd.SCHOOL_DATES_KEY
        INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES cd ON enr.CAL_DATE_KEY_END_ENROLL=cd.CALENDAR_DATE_KEY
           -- inner join K12INTEL_DW.DTBL_SCHOOLS  on K12INTEL_DW.FTBL_ENROLLMENTS.SCHOOL_KEY=K12INTEL_DW.DTBL_SCHOOLS.SCHOOL_KEY
          --  inner join K12INTEL_DW.DTBL_SCHOOLS_EXTENSION  on K12INTEL_DW.DTBL_SCHOOLS.SCHOOL_KEY=K12INTEL_DW.DTBL_SCHOOLS_EXTENSION.SCHOOL_KEY
    WHERE
         (SD.LOCAL_SCHOOL_YEAR =  '2014-2015'
          AND  enr.ENROLLMENT_TYPE = 'Actual'
         AND   (
                 Cd.DATE_VALUE  Is Null
                  OR
                  Cd.MONTH_OF_YEAR  <>  7
              )
          and (Cd.DATE_VALUE - sd.DATE_VALUE) > 2)
    GROUP BY
        enr.school_key
          ) enr on enr.school_key = sch.school_key
    LEFT OUTER JOIN
    (SELECT DISTINCT
      d.student_key
      ,d.school_key
    FROM
      K12INTEL_DW.FTBL_DISCIPLINE d
      INNER JOIN K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS da on d.discipline_key = da.discipline_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  actd on da.school_dates_key = actd.school_dates_key
      INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on d.school_key = sch.school_key
    WHERE
        actd.local_school_year in ('2014-2015')
        and da.discipline_action_type_code in ('OS', 'OSS', '33', '37')
        ) susp on susp.school_key = sch.school_key
    LEFT OUTER JOIN
    (SELECT DISTINCT
        prgm.student_key
        ,prgm.school_key
    FROM
        K12INTEL_DW.FTBL_PROGRAM_MEMBERSHIP prgm 
        INNER JOIN K12INTEL_DW.DTBL_PROGRAMS prg on prgm.program_key = prg.program_key
        INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES sd on sd.school_dates_key = prgm.begin_school_date_key
    WHERE 1=1
        and sd.date_value >= to_date('07-01-2014', 'MM-DD-YYYY')
        and prg.program_group = 'Behavior'
        ) intv on susp.student_key = intv.student_key and susp.school_key = intv.school_key
WHERE
    sch.reporting_school_ind = 'Y'
--    and sch.school_code = '18'
GROUP BY    
    sch.school_code
    ,sch.school_name
    ,enr.students
ORDER BY
    1