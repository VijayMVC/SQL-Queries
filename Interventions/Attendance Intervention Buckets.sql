SELECT 
    attd.student_key,
    attd.school_key,
    max(case when attd.intervention = 1 then attd.intv_number end) as max_level,
    sum(case when attd.bucket_sort = 1 then attd.absences else null end) AS bucket_1,
    sum(case when attd.bucket_sort = 2 then attd.absences else null end) AS bucket_2,
    sum(case when attd.bucket_sort = 3 then attd.absences else null end) AS bucket_3,
    sum( case when attd.bucket_sort = 4 then attd.absences else null end) AS bucket_4,
    sum(case when attd.bucket_sort = 5 then attd.absences else null end) AS bucket_5,
    sum(case when attd.bucket_sort = 6 then attd.absences else null end) AS bucket_6,
    sum(case when attd.bucket_sort = 7 then attd.absences else null end) AS bucket_7,
    sum(case when attd.bucket_sort = 8 then attd.absences else null end) AS bucket_8,
    sum(case when attd.bucket_sort = 9 then attd.absences else null end) AS bucket_9,
    sum(case when attd.bucket_sort = 10 then attd.absences else null end) AS bucket_10
FROM
    ( 
    SELECT 
        attd.student_key 
        ,attd.school_key 
        ,sd.bucket 
        ,sd.bucket_sort 
        ,count(attd.attendance_key) - sum(attd.attendance_value) as absences 
        ,case when sd.bucket_sort <= 4 and (count(attd.attendance_key) - sum(attd.attendance_value))  > 1  then 1 
                  when sd.bucket_sort > 4 and (count(attd.attendance_key) - sum(attd.attendance_value)) >= 3 then 1 
                  else 0 end as intervention 
        ,row_number() over (partition by attd.student_key, attd.school_key, case when sd.bucket_sort <= 4 and (count(attd.attendance_key) - sum(attd.attendance_value))  > 1  then 1 
                  when sd.bucket_sort > 4 and (count(attd.attendance_key) - sum(attd.attendance_value)) >= 3 then 1 
                  else 0 end ORDER BY sd.bucket_sort) as intv_number 
        ,row_number() over (partition by attd.student_key, attd.school_key, case when sd.bucket_sort <= 4 and (count(attd.attendance_key) - sum(attd.attendance_value))  > 1  then 1 
                  when sd.bucket_sort > 4 and (count(attd.attendance_key) - sum(attd.attendance_value)) >= 3 then 1 
                  else 0 end ORDER BY sd.bucket_sort desc) as intv_max   
    FROM 
        K12INTEL_DW.FTBL_ATTENDANCE attd 
        INNER JOIN 
        (SELECT 
            sd.school_dates_key 
            ,sd.date_value 
            ,case when sd.local_enroll_day_in_school_yr between 1 and 10 then '1-10' 
            when sd.local_enroll_day_in_school_yr between 11 and 20 then '11-20' 
            when sd.local_enroll_day_in_school_yr between 21 and 30 then '21-30' 
            when sd.local_enroll_day_in_school_yr between 31 and 42 then '31-42' 
            when sd.local_enroll_day_in_school_yr between 43 and 63 then '43-63' 
            when sd.local_enroll_day_in_school_yr between 64 and 86 then '64-86' 
            when sd.local_enroll_day_in_school_yr between 87 and 107 then '87-107' 
            when sd.local_enroll_day_in_school_yr between 108 and 128 then '108-128' 
            when sd.local_enroll_day_in_school_yr between 129 and 152 then '129-152' 
            when sd.local_enroll_day_in_school_yr between 153 and 175 then '153-175' 
            end as bucket 
            ,case when sd.local_enroll_day_in_school_yr between 1 and 10 then 1 
            when sd.local_enroll_day_in_school_yr between 11 and 20 then 2 
            when sd.local_enroll_day_in_school_yr between 21 and 30 then 3 
            when sd.local_enroll_day_in_school_yr between 31 and 42 then 4 
            when sd.local_enroll_day_in_school_yr between 43 and 63 then 5 
            when sd.local_enroll_day_in_school_yr between 64 and 86 then 6 
            when sd.local_enroll_day_in_school_yr between 87 and 107 then 7 
            when sd.local_enroll_day_in_school_yr between 108 and 128 then 8 
            when sd.local_enroll_day_in_school_yr between 129 and 152 then 9 
            when sd.local_enroll_day_in_school_yr between 153 and 175 then 10 
            end as bucket_sort 
        FROM 
            K12INTEL_DW.DTBL_SCHOOL_DATES sd 
        WHERE 
            sd.local_school_year = '2014-2015' 
            and sd.local_enroll_day_in_school_yr <= 175
        ) sd on sd.school_dates_key = attd.school_dates_key 
    WHERE 
        (1=1) 
    GROUP BY 
        attd.student_key 
        ,attd.school_key 
        ,sd.bucket 
        ,sd.bucket_sort 
    ) attd
WHERE
    attd.student_key = 18
GROUP BY
    attd.student_key,
    attd.school_key