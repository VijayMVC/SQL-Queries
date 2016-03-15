SELECT
    count(distinct dtbl_students.student_key) all_students
    ,count(distinct case when dtbl_students.student_special_ed_indicator = 'Yes' then dtbl_students.student_key else null end) as sped
    ,count(distinct case when dtbl_students.student_foodservice_indicator = 'Yes' then dtbl_students.student_key else null end) as econ_dis
    ,count(distinct case when dtbl_students.student_foodservice_indicator = 'No' then dtbl_students.student_key else null end) as not_econ_dis
    ,count(distinct case when dtbl_students.student_esl_indicator = 'Yes' then dtbl_students.student_key else null end) as ell
    ,count(distinct case when dtbl_students.student_esl_indicator != 'Yes' then dtbl_students.student_key else null end) as not_ell
    ,count(distinct case when dtbl_students.student_race = 'American Indian or Alaska Native' then dtbl_students.student_key else null end) as Native_am
    ,count(distinct case when dtbl_students.student_race = 'Asian' then dtbl_students.student_key else null end) as asian
    ,count(distinct case when dtbl_students.student_race = 'Black or African American' then dtbl_students.student_key else null end) as black
   ,count(distinct case when dtbl_students.student_race = 'Hispanic' then dtbl_students.student_key else null end) as hispanic
    ,count(distinct case when dtbl_students.student_race = 'White' then dtbl_students.student_key else null end) as white
    ,count(distinct case when dtbl_students.student_race = 'Native Hawaiian or Other Pacific Islander' then dtbl_students.student_key else null end) as hi_pi
    ,count(distinct case when dtbl_students.student_race = 'Multi' then dtbl_students.student_key else null end) as multi
FROM
     K12INTEL_DW.DTBL_STUDENTS
      INNER JOIN K12INTEL_DW.DTBL_SCHOOLS ON DTBL_STUDENTS.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY
      INNER JOIN K12INTEL_DW.DTBL_STUDENT_DETAILS ON DTBL_STUDENT_DETAILS.STUDENT_KEY = DTBL_STUDENTS.STUDENT_KEY
      INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION ON DTBL_SCHOOLS_EXTENSION.SCHOOL_KEY = DTBL_SCHOOLS.SCHOOL_KEY
      LEFT JOIN (SELECT student_key FROM
                      (SELECT sc.*, row_number() over (Partition by sc.student_key, sc.subject ORDER BY date_value desc, test_primary_result_code desc, test_items_attempted desc) r
                      FROM k12intel_dw.mps_mv_star_component_scores sc
                      WHERE  sc.school_year='2015-2016'
                      )
                      WHERE r = 1
                      AND test_primary_result_code = '1'
                      and subject = 'Mathematics'
                      ) str on str.student_key = dtbl_students.student_key
          
--      LEFT JOIN (SELECT pm.student_key
--                  FROM K12INTEL_DW.DTBL_PROGRAMS P
--                      inner join k12intel_dw.ftbl_program_membership PM
--                      on PM.program_key = p.program_key
--                      and pm.membership_status = 'Active'
--                      inner join k12intel_dw.dtbl_school_dates bdsd
--                      on pm.begin_school_date_key = bdsd.school_dates_key
--                                and bdsd.rolling_local_school_yr_number = 0
--                  WHERE program_type = 'Programs'
--                  and  p.PROGRAM_key = '78236'
--                  ) cogat
--                  on cogat.STUDENT_KEY = dtbl_students.student_key
WHERE
     (dtbl_schools.school_key IN ('819', '2332', '724', '162', '425', '745', '178', '848', '997', '727', '747', '2334', '992', '2358', '773', '748', '708', '2312', '828', '709', '749', '750', '427', '751', '752', '428', '730', '2361', '972', '445', '180', '754', '850', '429', '756', '755', '161', '430', '757', '846', '758', '431', '710', '849', '2319', '759', '432', '762', '457', '763', '434', '765', '435', '767', '769', '770', '771', '772', '418', '438', '485', '439', '158', '775', '854', '776', '777', '441', '779', '712', '872', '520', '711', '780', '781', '782', '443', '783', '784', '853', '165', '785', '823', '786', '2333', '787', '788', '1210', '833', '790', '791', '793', '426', '713', '999', '824', '734', '141', '142', '456', '461', '885', '794', '795', '798', '706', '799', '800', '801', '802', '973', '803', '805', '707', '806', '462', '437', '807', '976', '970', '843', '2313', '2318', '2294', '2359', '2316', '761', '433', '726', '451', '715', '744', '789', '768', '808', '931', '809', '419', '810', '718', '888', '811', '2335', '1000', '969', '864', '875', '4998', '450', '2336', '444', '2293', '815', '138', '463', '869', '717', '139', '5043', '446', '440', '720', '172', '422', '987', '968', '2314', '464', '820', '447', '821', '822', '448', '722', '862', '844', '2321', '990', '839', '858', '887', '876', '818', '764', '891', '449', '825', '829', '766', '2309', '830', '2315', '1206', '831', '2360', '835', '454', '723', '2337', '174', '176', '971', '452', '797', '836', '837', '269', '268', '868', '893', '455', '892', '975', '812'))
      AND (dtbl_students.student_status = 'Enrolled')
 --     and (cogat.student_key is not null or 
      and str.student_key is not null