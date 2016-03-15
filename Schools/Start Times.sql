SELECT
   stsv.esis_id,
--   stsv.school_type,
--   stsv.mps_sch_group,
--   stsv.mps_sch_category,
   ent.name_short,
   ent.school_year_fall,
   sp.class_start_time,
   sp.class_end_time
FROM
	ENTITY.ENTITIES ent
	INNER JOIN ENTITY.STUDENT_SERVICES_PROFILE stsv on ent.entity_id = stsv.entity_id and ent.school_year_fall = stsv.school_year_fall
	INNER JOIN ENTITY.SCHOOL_PROFILE sp on ent.entity_id = sp.entity_id and ent.school_year_fall = sp.school_year_fall
    INNER JOIN ENTITY.RESEARCH_PROFILE rp on ent.entity_id = rp.entity_id  and ent.school_year_fall = rp.school_year_fall
WHERE
	rp.incl_on_report_card = 'Y' and
	stsv.mps_sch_group = 1 and
	ent.school_year_fall >= 2003 and
	ent.name_short is not null
ORDER BY 1,3
