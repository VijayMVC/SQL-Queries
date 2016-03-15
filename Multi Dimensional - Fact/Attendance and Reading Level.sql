SELECT
    attendance_level_kor1
    ,count(distinct student_id) as all_students
    ,count(distinct (case when reading_level = 'On Grade Level' then student_id else null end)) as on_grade_level_readers
    ,count(distinct (case when reading_level = 'Not on Grade Level' then student_id else null end)) as below_grade_level_readers
    ,round(count(distinct (case when reading_level = 'On Grade Level' then student_id else null end))/count(distinct student_id),3) as percent_on_grade_level
FROM
(SELECT
    st.student_id
    ,case when reading.test_primary_result_code in ('1', '2') then 'On Grade Level' else 'Not on Grade Level' end as reading_level
    ,CASE WHEN sum(attd.attendance_days - attd.attendance_value) <= 9 and sum(attd2.attendance_days - attd2.attendance_value) <= 9 THEN 'Good'
          when sum(attd.attendance_days - attd.attendance_value) >= 18 and sum(attd2.attendance_days - attd2.attendance_value) >= 18 then 'Absentee' 
          when sum(attd.attendance_days - attd.attendance_value) between 9.5 and 17.5 and sum(attd2.attendance_days - attd2.attendance_value) between 9.5 and 17.5 then 'At-Risk' 
          else 'NA' end as attendance_level_kand1
    ,CASE WHEN sum(attd.attendance_days - attd.attendance_value) >= 18 or sum(attd2.attendance_days - attd2.attendance_value) >= 18 then 'Absentee' 
          else 'NA' end as attendance_level_kor1
FROM
    K12INTEL_DW.DTBL_STUDENTS st
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = st.school_key
    INNER JOIN K12INTEL_DW.FTBL_ATTENDANCE_STUSUMMARY attd on attd.student_key = st.student_key and attd.local_school_year = '2012-2013'
    INNER JOIN K12INTEL_DW.FTBL_ATTENDANCE_STUSUMMARY attd2 on attd2.student_key = st.student_key and attd2.local_school_year = '2013-2014'
    LEFT JOIN (SELECT * FROM
              (SELECT sc.*, row_number() over (Partition by sc.student_key, sc.subject ORDER BY date_value desc, test_primary_result_code desc, test_items_attempted desc) r
              FROM k12intel_dw.mps_mv_star_component_scores sc
              WHERE  sc.school_year='2015-2016'
              and subject = 'Reading'
              )
              WHERE r = 1
              ) reading on reading.student_key = st.student_key
WHERE
    st.student_current_grade_code = '03'
    and st.student_status = 'Enrolled' and sch.reporting_school_ind = 'Y'
GROUP BY
    st.student_id
    ,case when reading.test_primary_result_code in ('1', '2') then 'On Grade Level' else 'Not on Grade Level' end
) comb
WHERE comb.attendance_level_kor1 != 'NA'
GROUP BY   attendance_level_kor1