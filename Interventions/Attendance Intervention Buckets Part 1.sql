SELECT 
     case when attd.intv_number > 4 then 4 else attd.intv_number end AS "C8875",
     Count(Distinct dtbl_students.student_key) AS "C435"
FROM
           K12INTEL_DW.DTBL_STUDENTS 
               INNER JOIN 
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
                       ) sd on sd.school_dates_key = attd.school_dates_key 
                WHERE 
                        (1=1) 
                GROUP BY 
                       attd.student_key 
                       ,attd.school_key 
                       ,sd.bucket 
                       ,sd.bucket_sort 
                   --ORDER BY 1,4 
                   ) attd  on attd.student_key = dtbl_students.student_key 
                 INNER JOIN K12INTEL_DW.DTBL_SCHOOLS on  attd.school_key = dtbl_schools.school_key
WHERE
     (dtbl_students.student_current_grade_code = '09'
          and intervention = 1)
      AND (1=1)
      AND (1=1)
      AND (1=1)
      AND (1=1)
      AND (1=1)
      AND (( 
          (SELECT dbms_random.string('P',5) FROM dual)='Programs' 
          OR 
          1=1   
          OR 
          EXISTS 
          ( 
              SELECT 1 
              FROM K12INTEL_DW.DTBL_PROGRAMS 
          inner join k12intel_dw.ftbl_program_membership 
          on k12intel_dw.ftbl_program_membership.program_key = K12INTEL_DW.DTBL_PROGRAMS.program_key 
          inner join k12intel_dw.dtbl_school_dates bdsd 
          on k12intel_dw.ftbl_program_membership.begin_school_date_key = bdsd.school_dates_key 
                    and bdsd.rolling_local_school_yr_number = 0 
          WHERE program_type = 'Programs' 
          and  1=1 
          and K12INTEL_DW.DTBL_STUDENTS.STUDENT_KEY = k12intel_dw.ftbl_program_membership.student_key 
          )))
      AND (dtbl_schools.school_key IN ('819', '2332', '724', '162', '425', '745', '178', '848', '997', '727', '747', '2334', '992', '2358', '773', '748', '708', '2312', '828', '709', '749', '750', '427', '751', '752', '428', '730', '2361', '972', '445', '180', '754', '850', '429', '756', '755', '161', '430', '757', '846', '758', '431', '710', '849', '2319', '759', '432', '762', '457', '763', '434', '765', '435', '767', '769', '770', '771', '772', '418', '438', '485', '439', '158', '775', '854', '776', '777', '441', '779', '712', '872', '520', '711', '780', '781', '782', '443', '783', '784', '853', '165', '785', '823', '786', '2333', '787', '788', '1210', '833', '790', '791', '793', '426', '713', '999', '824', '734', '141', '142', '456', '461', '885', '794', '795', '798', '706', '799', '800', '801', '802', '973', '803', '805', '806', '462', '437', '807', '976', '970', '843', '2313', '2318', '2294', '2359', '2316', '761', '433', '726', '451', '715', '744', '789', '768', '808', '931', '809', '419', '810', '718', '888', '811', '2335', '1000', '969', '864', '875', '4998', '450', '2336', '444', '2293', '815', '138', '463', '869', '717', '139', '5043', '446', '440', '720', '172', '422', '987', '968', '2314', '464', '820', '447', '821', '822', '448', '722', '862', '844', '2321', '990', '839', '858', '887', '876', '818', '764', '891', '449', '825', '829', '766', '2309', '830', '2315', '1206', '831', '2360', '835', '454', '723', '2337', '174', '971', '452', '797', '836', '837', '176', '269', '268', '868', '893', '455', '892', '975', '812'))
      AND (1=1)
GROUP BY
     case when attd.intv_number > 4 then 4 else attd.intv_number end
ORDER BY
     case when attd.intv_number > 4 then 4 else attd.intv_number end
