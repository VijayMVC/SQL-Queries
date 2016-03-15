SELECT
   pa.*
FROM
     K12INTEL_DW.MPSF_PERIOD_ATTENDANCE pa
          inner join k12intel_dw.dtbl_schools sch on pa.school_key = sch.school_key 
          inner join k12intel_dw.dtbl_students st on st.student_key = pa.student_key
          inner join k12intel_dw.dtbl_student_annual_attribs staa on staa.student_annual_attribs_key = pa.student_annual_attribs_key
          inner join k12intel_dw.dtbl_school_dates sd on sd.school_dates_key = pa.school_dates_key
--          inner join k12intel_dw.dtbl_courses c on pa.course_key = c.course_key 
--          inner join K12INTEL_DW.DTBL_COURSE_OFFERINGS co on pa.course_offerings_key = co.course_offerings_key  
           
WHERE 1=1
   and sd.local_school_year = '2015-2016' 
   and sd.date_value between to_date('09-02-15', 'MM-DD-YY') AND to_date('09-02-15', 'MM-DD-YY')
   and pa.course_period = '03'
    and sch.school_code = '12'
    and attendance_type = 'Absent'
    ;
select
    sum(attendance_value)
from
    k12intel_dw.mps_mv_perd_attend_schstu pa
    inner join k12intel_dw.dtbl_school_dates sd on sd.school_dates_key = pa.school_dates_key
where 1=1
       and sd.date_value between to_date('09-02-15', 'MM-DD-YY') AND to_date('09-02-15', 'MM-DD-YY')
   and pa.course_period = '03'
    and school_KEY = 708
--    and attendance_type = 'Absent'