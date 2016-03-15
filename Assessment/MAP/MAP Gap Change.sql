SELECT
     school_code as "School Code",
     school_name as "School Name",
     Dsort  AS "Sort",
     Grade AS "Grade Level",
     Fall AS "Fall Gap",
     Winter AS "Winter Gap",
     Spring AS "Spring Gap",
     case when Fall >= 0 and Winter >= 0 then 'No Gap' else cast (round(Winter - Fall,2) as varchar(6)) end AS "Fall to Winter Gap Change",
     case when Winter >= 0 and Fall >= 0 then 'No Gap'
               when Fall <> 0 and  Winter = 0 then to_char(round (((Winter-Fall)/nullif(Fall,0)) ,3)) --||'%'
               else  to_char(round(((Winter-Fall)/nullif(Fall,0)),3)) end AS "Fall to Winter Pct Change", -- * 100,1)||'%'
     case when Fall >= 0 and Spring >= 0 then 'No Gap' else cast (round(Spring - Fall,2) as varchar(6)) end AS "Fall to Spring Gap Change",
     case when Spring >= 0 and Fall >= 0 then 'No Gap'
               when Fall <> 0 and  Spring = 0 then to_char(round (((Spring-Fall)/nullif(Fall,0)) ,3)) --||'%'
               else  to_char(round(((Spring-Fall)/Fall),3))  end AS "Fall to Spring Pct Change" --* 100,1)||'%'
FROM
     (SELECT
            dtbl_schools.school_code,
            dtbl_schools.school_name,
           round(avg(MPS_MV_MAP_COMPONENT_SCORES.TEST_SCALED_SCORE - MPS_MV_MAP_COMPONENT_SCORES.TARGET_RIT_SCORE),1)  Average_Gap,
           MPS_MV_MAP_COMPONENT_SCORES.SEASON,
           Grade , 
            subject ,
            MPS_MV_MAP_COMPONENT_SCORES.school_year,
            case when grade = 'K5' then 0 else 1 end Dsort
          FROM
          K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES
          inner join k12intel_dw.dtbl_schools on dtbl_schools.school_key = mps_mv_map_component_scores.school_key
          inner join K12INTEL_DW.DTBL_STUDENTS on MPS_MV_MAP_COMPONENT_SCORES.STUDENT_KEY = DTBL_STUDENTS.STUDENT_KEY
          inner join K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on MPS_MV_MAP_COMPONENT_SCORES.STUDENT_ANNUAL_ATTRIBS_KEY = DTBL_STUDENT_ANNUAL_ATTRIBS.STUDENT_ANNUAL_ATTRIBS_KEY
          WHERE
           K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES.TEST_STUDENT_GRADE  IN  ( 'K5','01','02','03','04','05','06','07','08','09','10','11'  )
          AND   K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES.TEST_SCALED_SCORE  >  0
          AND (subject IN ('Mathematics')
           and MPS_MV_MAP_COMPONENT_SCORES.SCHOOL_YEAR IN ('2014-2015'))
          AND 1=1
          AND MPS_MV_MAP_COMPONENT_SCORES.school_key IN ('819', '2332', '724', '162', '425', '745', '178', '848', '997', '727', '747', '2334', '992', '2358', '773', '748', '708', '2312', '828', '709', '749', '750', '427', '751', '752', '428', '730', '2361', '972', '445', '180', '754', '850', '429', '756', '755', '161', '430', '757', '846', '758', '431', '710', '849', '2319', '759', '432', '762', '457', '763', '434', '765', '435', '767', '769', '770', '771', '772', '418', '438', '485', '439', '158', '775', '854', '776', '777', '441', '779', '712', '872', '520', '711', '780', '781', '782', '443', '783', '784', '853', '165', '785', '823', '786', '2333', '787', '788', '1210', '833', '790', '791', '793', '426', '713', '999', '824', '734', '141', '142', '456', '461', '885', '794', '795', '798', '706', '799', '800', '801', '802', '973', '803', '805', '806', '462', '437', '807', '976', '970', '843', '2313', '2318', '2294', '2359', '2316', '761', '433', '726', '451', '715', '744', '789', '768', '808', '931', '809', '419', '810', '718', '888', '811', '2335', '1000', '969', '864', '875', '4998', '450', '2336', '444', '2293', '815', '138', '463', '869', '717', '139', '5043', '446', '440', '720', '172', '422', '987', '968', '2314', '464', '820', '447', '821', '822', '448', '722', '862', '844', '2321', '990', '839', '858', '887', '876', '818', '764', '891', '449', '825', '829', '766', '2309', '830', '2315', '1206', '831', '2360', '835', '454', '723', '2337', '174', '971', '452', '797', '836', '837', '176', '269', '268', '868', '893', '455', '892', '975', '812')
          AND 1=1
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
                    and rownum < 2
                    )))
          AND 1=1
          AND 1=1
          AND ((
                    (SELECT dbms_random.string('P',5) FROM dual)='Cohort Schools'
                    OR 
                    
                    1=1   
                    OR 
                    EXISTS 
                    (
                        SELECT 1
                        FROM K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS
                        WHERE  1=1
                        AND MPS_MV_MAP_COMPONENT_SCORES.SCHOOL_KEY = K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS.SCHOOL_KEY  
                        and rownum < 2 
                    )))
          AND 1=1
          AND 1=1
          GROUP BY
          dtbl_schools.school_code,
            dtbl_schools.school_name,
           MPS_MV_MAP_COMPONENT_SCORES.SEASON,
           Grade, subject ,MPS_MV_MAP_COMPONENT_SCORES.school_year
          UNION all
          --
          -- Generate the Total Line
          --
          SELECT
            dtbl_schools.school_code,
            dtbl_schools.school_name,
           round(avg(MPS_MV_MAP_COMPONENT_SCORES.TEST_SCALED_SCORE - MPS_MV_MAP_COMPONENT_SCORES.TARGET_RIT_SCORE),1)  ,
           MPS_MV_MAP_COMPONENT_SCORES.SEASON,
          'Total' ,
          subject ,MPS_MV_MAP_COMPONENT_SCORES.school_year  
           ,2
           FROM
          K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES
          inner join k12intel_dw.dtbl_schools on dtbl_schools.school_key = mps_mv_map_component_scores.school_key
          inner join K12INTEL_DW.DTBL_SCHOOL_ANNUAL_ATTRIBS on MPS_MV_MAP_COMPONENT_SCORES.School_Annual_Attribs_key = DTBL_SCHOOL_ANNUAL_ATTRIBS.School_Annual_Attribs_key
          inner join K12INTEL_DW.DTBL_STUDENTS on MPS_MV_MAP_COMPONENT_SCORES.STUDENT_KEY = DTBL_STUDENTS.STUDENT_KEY
          inner join K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on MPS_MV_MAP_COMPONENT_SCORES.STUDENT_ANNUAL_ATTRIBS_KEY = DTBL_STUDENT_ANNUAL_ATTRIBS.STUDENT_ANNUAL_ATTRIBS_KEY
          WHERE
          MPS_MV_MAP_COMPONENT_SCORES.TEST_STUDENT_GRADE  IN  ( 'K5','01','02','03','04','05','06','07','08','09','10','11'  )
          and DTBL_SCHOOL_ANNUAL_ATTRIBS.REPORTING_SCHOOL_IND   = 'Y'
          AND   K12INTEL_DW.MPS_MV_MAP_COMPONENT_SCORES.TEST_SCALED_SCORE  >  0
          AND (subject IN ('Mathematics')
          and MPS_MV_MAP_COMPONENT_SCORES.SCHOOL_YEAR IN ('2014-2015'))
          AND (1=1)
          AND (MPS_MV_MAP_COMPONENT_SCORES.school_key IN ('819', '2332', '724', '162', '425', '745', '178', '848', '997', '727', '747', '2334', '992', '2358', '773', '748', '708', '2312', '828', '709', '749', '750', '427', '751', '752', '428', '730', '2361', '972', '445', '180', '754', '850', '429', '756', '755', '161', '430', '757', '846', '758', '431', '710', '849', '2319', '759', '432', '762', '457', '763', '434', '765', '435', '767', '769', '770', '771', '772', '418', '438', '485', '439', '158', '775', '854', '776', '777', '441', '779', '712', '872', '520', '711', '780', '781', '782', '443', '783', '784', '853', '165', '785', '823', '786', '2333', '787', '788', '1210', '833', '790', '791', '793', '426', '713', '999', '824', '734', '141', '142', '456', '461', '885', '794', '795', '798', '706', '799', '800', '801', '802', '973', '803', '805', '806', '462', '437', '807', '976', '970', '843', '2313', '2318', '2294', '2359', '2316', '761', '433', '726', '451', '715', '744', '789', '768', '808', '931', '809', '419', '810', '718', '888', '811', '2335', '1000', '969', '864', '875', '4998', '450', '2336', '444', '2293', '815', '138', '463', '869', '717', '139', '5043', '446', '440', '720', '172', '422', '987', '968', '2314', '464', '820', '447', '821', '822', '448', '722', '862', '844', '2321', '990', '839', '858', '887', '876', '818', '764', '891', '449', '825', '829', '766', '2309', '830', '2315', '1206', '831', '2360', '835', '454', '723', '2337', '174', '971', '452', '797', '836', '837', '176', '269', '268', '868', '893', '455', '892', '975', '812'))
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
                    and rownum < 2
                    )))
          AND 1=1
          AND 1=1
                AND ((
                    (SELECT dbms_random.string('P',5) FROM dual)='Cohort Schools'
                    OR 
                    
                    1=1   
                    OR 
                    EXISTS 
                    (
                        SELECT 1
                        FROM K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS
                        WHERE  1=1
                        AND MPS_MV_MAP_COMPONENT_SCORES.SCHOOL_KEY = K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS.SCHOOL_KEY  
                        and rownum < 2 
                    )))
          AND 1=1
          AND 1=1
          GROUP BY
           dtbl_schools.school_code, dtbl_schools.school_name, MPS_MV_MAP_COMPONENT_SCORES.SEASON, subject, MPS_MV_MAP_COMPONENT_SCORES.school_year
              ) School
          pivot
               (max(average_gap)
                 for Season in ('Fall' as Fall,'Winter' as Winter,'Spring' as Spring))
ORDER BY
     school_name,
     Dsort ,
     Grade
