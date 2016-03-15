SELECT
	SCHOOL_YEAR_FaLL,
	esis_id,
	NAME_SHORT,
	school_type,
	DPI_School_level,
	grade_low,
	grade_high,
	active_grades_low,
	active_grades_high,
	charter_ind,
	charter_type
from
	K12INTEL_STAGING.ENT_ENTITY_MASTER_VIEW
where
	incl_on_report_card = 'Y'
	and school_year_fall in ('2012')

