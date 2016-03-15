SELECT
  sch.school_code,
  sch.school_name,
  sd.local_school_year,
  count(distinct case when fda.discipline_action_type_code = '32' then fda.discipline_action_key else null end) as in_schl_suspension
from
  k12intel_dw.dtbl_students s,
  K12INTEL_DW.DTBL_SCHOOLs sch,
  K12INTEL_DW.DTBL_SCHOOL_DATES sd,
  K12INTEL_DW.FTBL_DISCIPLINE fd,
  K12INTEL_DW.FTBL_DISCIPLINE_ACTIONS fda
WHERE
  fd.DISCIPLINE_KEY=fda.DISCIPLINE_KEY   and
     fda.STUDENT_KEY = s.STUDENT_KEY    and
     fda.SCHOOL_DATES_KEY=sd.SCHOOL_DATES_KEY   and
     fda.school_key = sch.school_key  and
     fda.student_key = se.student_key  and
   ( sd.local_school_year = '2013-2014' ) and
   ( sch.school_code in ('173', '232', '235', '356', '370', '319', '83', '307'))
	-- and ( sch.school_code = '33' )
group by
  sch.school_name,
  sch.school_code,
  sd.local_school_year
ORDER BY
	2
