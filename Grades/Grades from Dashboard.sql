SELECT
     dtbl_schools.school_code,
     dtbl_schools.school_name,
     dtbl_school_dates.local_school_year,
     case dtbl_courses.course_subject
              when 'English Language and Literature' then 'English Language Arts'
              when 'Fine and Performing Arts' then 'Fine & Performing Arts'
              when 'Foreign Language and Literature' then 'World Languages'
              when 'Life and Physical Sciences' then 'Science'
              when 'Mathematics' then 'Mathematics'
              when 'Physical, Health, and Safety Education' then 'Health & PE'
              when 'Social Sciences and History' then 'Social Studies'
              else 'Other Electives'
          end AS "Subjects",
     rtrim(dtbl_scales.scale_abbreviation) AS "Grades",
     count(FTBL_STUDENT_MARKS.STUDENT_MARKS_KEY) AS "Count"
 --   count(ftbl_student_marks.student_marks_key) over (partition by dtbl_schools.school_code) as all_marks
FROM
     K12INTEL_DW.FTBL_STUDENT_MARKS
          INNER JOIN K12INTEL_DW.DTBL_STUDENTS ON FTBL_STUDENT_MARKS.STUDENT_KEY = DTBL_STUDENTS.STUDENT_KEY
          --INNER JOIN K12INTEL_DW.DTBL_STUDENTS_EXTENSION ON FTBL_STUDENT_MARKS.STUDENT_KEY = DTBL_STUDENTS_EXTENSION.STUDENT_KEY
          --INNER JOIN K12INTEL_DW.DTBL_STUDENT_ATTRIBS ON DTBL_STUDENTS.STUDENT_ATTRIB_KEY = DTBL_STUDENT_ATTRIBS.STUDENT_ATTRIB_KEY
          INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS ON FTBL_STUDENT_MARKS.STUDENT_ANNUAL_ATTRIBS_KEY = DTBL_STUDENT_ANNUAL_ATTRIBS.STUDENT_ANNUAL_ATTRIBS_KEY
          INNER JOIN K12INTEL_DW.DTBL_SCHOOLS ON FTBL_STUDENT_MARKS.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY
          --INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION ON FTBL_STUDENT_MARKS.SCHOOL_KEY = DTBL_SCHOOLS_EXTENSION.SCHOOL_KEY
          INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES ON FTBL_STUDENT_MARKS.SCHOOL_DATES_KEY = DTBL_SCHOOL_DATES.SCHOOL_DATES_KEY
          --INNER JOIN K12INTEL_DW.DTBL_CALENDAR_DATES ON FTBL_STUDENT_MARKS.CALENDAR_DATE_KEY = DTBL_CALENDAR_DATES .CALENDAR_DATE_KEY
          INNER JOIN K12INTEL_DW.DTBL_COURSES ON FTBL_STUDENT_MARKS.COURSE_KEY = DTBL_COURSES.COURSE_KEY
          --INNER JOIN K12INTEL_DW.DTBL_COURSE_OFFERINGS ON FTBL_STUDENT_MARKS.COURSE_OFFERINGS_KEY = DTBL_COURSE_OFFERINGS.COURSE_OFFERINGS_KEY
          --INNER JOIN K12INTEL_DW.DTBL_STAFF ON DTBL_COURSE_OFFERINGS.STAFF_KEY = DTBL_STAFF.STAFF_KEY
          --INNER JOIN K12INTEL_DW.DTBL_ROOMS ON FTBL_STUDENT_MARKS.ROOM_KEY = DTBL_ROOMS.ROOM_KEY
          INNER JOIN K12INTEL_DW.DTBL_SCALES ON FTBL_STUDENT_MARKS.SCALE_KEY = DTBL_SCALES.SCALE_KEY
          --INNER JOIN K12INTEL_USERDATA.XTBL_DOMAIN_DECODES DOMAIN_GRADE_CODE ON DOMAIN_GRADE_CODE.DOMAIN_NAME = 'GRADE_CODE' AND DOMAIN_GRADE_CODE.DOMAIN_CODE = DTBL_STUDENTS.STUDENT_CURRENT_GRADE_CODE
          --LEFT OUTER JOIN K12INTEL_DW.DTBL_STUDENT_COHORT_MEMBERS on (DTBL_STUDENTS.STUDENT_KEY = DTBL_STUDENT_COHORT_MEMBERS.STUDENT_KEY AND (@@PROMPT StudentCohort,"DTBL_STUDENT_COHORT_MEMBERS.COHORT_NAME",IN,promptdefault,"1<>1",string)))
     --1=1
WHERE
     ftbl_student_marks.mark_type = 'Period'
          and dtbl_school_dates.local_school_year IN ('2014-2015')
--          and dtbl_students.student_activity_indicator = 'Active' and dtbl_students.student_status = 'Enrolled'
          and dtbl_student_annual_attribs.STUDENT_ANNUAL_GRADE_CODE IN ('09')
          and rtrim(dtbl_scales.scale_abbreviation) in ('A','B','C','D','U')
GROUP BY
     case dtbl_courses.course_subject
              when 'English Language and Literature' then 'English Language Arts'
              when 'Fine and Performing Arts' then 'Fine & Performing Arts'
              when 'Foreign Language and Literature' then 'World Languages'
              when 'Life and Physical Sciences' then 'Science'
              when 'Mathematics' then 'Mathematics'
              when 'Physical, Health, and Safety Education' then 'Health & PE'
              when 'Social Sciences and History' then 'Social Studies'
              else 'Other Electives'
          end,
          dtbl_schools.school_code,
     dtbl_schools.school_name,
     dtbl_school_dates.local_school_year,
     rtrim(dtbl_scales.scale_abbreviation)
ORDER BY
     case dtbl_courses.course_subject
              when 'English Language and Literature' then 'English Language Arts'
              when 'Fine and Performing Arts' then 'Fine & Performing Arts'
              when 'Foreign Language and Literature' then 'World Languages'
              when 'Life and Physical Sciences' then 'Science'
              when 'Mathematics' then 'Mathematics'
              when 'Physical, Health, and Safety Education' then 'Health & PE'
              when 'Social Sciences and History' then 'Social Studies'
              else 'Other Electives'
          end,
     rtrim(dtbl_scales.scale_abbreviation)
