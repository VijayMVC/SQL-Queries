SELECT
	 st.student_id,
	 sd.local_school_year as school_year,
	 count(mrk.student_marks_key) as marks,
	 sum(case when scl.scale_code in ('PR','AD') then 1 else 0 end) as proficient_marks,
	 round(sum(case when scl.scale_code in ('PR','AD') then 1 else 0 end)/count(mrk.student_marks_key) ,3) as pct_proficient
--	 sch.school_code,
--	 sch.school_name,
--     se.student_current_grade_code as student_grade_level,
--	 cur.CURRICULUM_SORT,
--     case when (cur.curriculum_level_1 like 'Reading%') then 'Reading'
--          when (cur.curriculum_level_1 like 'English Reading%') then 'Reading'
--          when (cur.curriculum_level_1 like 'English Language Arts%'  and cur.curriculum_level_2 not like 'Writing%') then 'English Language Arts'
--          when (cur.curriculum_level_1 like 'Language A ( English)%') then 'English Language Arts'
--          when (cur.curriculum_level_1 like 'Math%') then 'Math'
--          when (cur.curriculum_level_1 like 'Social%') then 'Social Studies'
--          when (cur.curriculum_level_1 like 'Humanities%') then 'Social Studies'
--          when (cur.curriculum_level_1 like 'Science%') then 'Science'
--          when ((cur.curriculum_level_1 like 'English Language Arts%') AND (cur.curriculum_level_2 like 'Writing%')) then 'Writing'
--          when (cur.curriculum_level_1 like 'Language A ( English)%') then 'Writing'
--          else null
--          end as Subject
--     cur.curriculum_level_2 as curriculum_level,
--     mrk.mark_period,                                 -- always 1,2,3 and 10 for final at end of school year  (Anne cleaned all this up - should all be 1,2,3 and 10 only if looking at only curr mark schools (note that other schools might be using curr marks on their own but they are not valid and they might have weird mark periods))
--	 sd.date_value as mark_period_end_date,          -- from esis report_cycles end date
--     scl.scale_code,
--     case when scl.scale_code = '@ERR' then null else scl.scale_code end as scale_code,       -- convert @err to null for when kid didn't get a score for a particular mark period
--     case when scl.scale_description = '@ERR' then null else scl.scale_description end as scale_description
FROM
	k12intel_Dw.ftbl_student_marks mrk
	INNER JOIN k12intel_dw.dtbl_curriculum cur on mrk.curriculum_key=cur.CURRICULUM_KEY
    INNER JOIN k12intel_dw.dtbl_school_dates sd on mrk.school_dates_key=sd.school_dates_key
    INNER JOIN k12intel_dw.dtbl_students st on mrk.student_key = st.student_key
    INNER JOIN k12intel_dw.dtbl_scales scl on mrk.scale_key = scl.scale_key
    INNER JOIN k12intel_dw.dtbl_schools sch on mrk.school_key=sch.school_key
    INNER JOIN k12intel_dw.dtbl_students_evolved se on mrk.student_evolve_key=se.student_evolve_key
WHERE
	mrk.mark_type = 'Curriculum'
	and se.student_current_grade_code in ('07')
	and sd.local_school_year = '2013-2014'
	and (scl.scale_type  in ('@ERR','CURRICULUM MARKS') )
	and (cur.curriculum_level_2 not like 'Effort%')
	and mrk.mark_period = '10'
	           --  Effort is not an academic standard so exclude per Anne Knackert
	and (
   	cur.curriculum_level_1 like 'Reading%'
	   or cur.curriculum_level_1 like 'English Reading%'
	   or cur.curriculum_level_1 like 'English Language Arts%'
	   or cur.curriculum_level_1 like 'Language A ( English)%'
	   or cur.curriculum_level_1 like 'Math%'
	   or cur.curriculum_level_1 like 'Social%'
	   or cur.curriculum_level_1 like 'Humanities%'
	   or cur.curriculum_level_1 like 'Science%'
	   )
	and (scl.scale_code in ('PR','AD','BA','MI'))          -- comment out to include null scores for when kids did not get tested for that mark period
--   	and (sch.school_code='179')
--  and (st.student_id='8540080')
GROUP BY
	 st.student_id,
	 sd.local_school_year
--	 case when (cur.curriculum_level_1 like 'Reading%') then 'Reading'
--          when (cur.curriculum_level_1 like 'English Reading%') then 'Reading'
--          when (cur.curriculum_level_1 like 'English Language Arts%'  and cur.curriculum_level_2 not like 'Writing%') then 'English Language Arts'
--          when (cur.curriculum_level_1 like 'Language A ( English)%') then 'English Language Arts'
--          when (cur.curriculum_level_1 like 'Math%') then 'Math'
--          when (cur.curriculum_level_1 like 'Social%') then 'Social Studies'
--          when (cur.curriculum_level_1 like 'Humanities%') then 'Social Studies'
--          when (cur.curriculum_level_1 like 'Science%') then 'Science'
--          when ((cur.curriculum_level_1 like 'English Language Arts%') AND (cur.curriculum_level_2 like 'Writing%')) then 'Writing'
--          when (cur.curriculum_level_1 like 'Language A ( English)%') then 'Writing'
--          else null end
order by 1 ;
