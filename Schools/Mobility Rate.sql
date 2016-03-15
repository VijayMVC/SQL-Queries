SELECT
--  aids.school_of_record_code as school_code ,
--  aids.school_of_record_name as school_name,
  aids.collection_year as school_year,
  count(distinct mob_det.STUDENT_ID) as mobile_students,
  count(distinct aids.student_id) as tfriday_count,
  round ( count(distinct mob_det.STUDENT_ID)/count(distinct aids.student_id), 3) as mobility_rate
FROM
  K12INTEL_DW.MPSD_STATE_AIDS aids
  LEFT OUTER JOIN DAAADMIN.MOBILITY_DETAIL mob_det on mob_det.school_code = aids.school_of_record_code
  													and substr(aids.collection_year,1,4) = mob_det.year
WHERE
    (collection_period = 'September 3rd Friday' and
	school_group not in ('OPEN ENROLLMENT', 'CHAPTER 220', 'NOT IN USE') and
	collection_type = 'PRODUCTION' and
	student_countable_indicator = 'Yes' and
	collection_year in ( '2009-2010', '2010-2011', '2011-2012', '2012-2013'))
GROUP BY
--  aids.school_of_record_code,
--  aids.school_of_record_name,
  aids.collection_year
ORDER BY 1

