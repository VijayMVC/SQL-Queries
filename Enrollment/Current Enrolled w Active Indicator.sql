SELECT
--	count (distinct st.student_id) as students
	st.student_id
	,st.student_activity_indicator
	,st.student_status
	,sch.school_code
	,sch.school_name
	,st.student_current_grade_code
	,enr.entry_grade_code
	,adm_sd.date_value as admit_date
	,enr.withdraw_date
	,enr.withdraw_reason_code
	,enr.enrollment_days
FROM
  K12INTEL_DW.DTBL_STUDENTS st
  INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_key = st.school_key
  LEFT OUTER JOIN (K12INTEL_DW.FTBL_ENROLLMENTS enr
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  adm_sd on enr.school_dates_key_begin_enroll = adm_sd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  reg_sd on enr.school_dates_key_register=reg_sd.school_dates_key
  INNER JOIN K12INTEL_DW.DTBL_SCHOOL_DATES  end_sd on enr.school_dates_key_end_enroll = end_sd.school_dates_key
  ) on enr.school_key = st.school_key and enr.student_key = st.student_key
WHERE
	st.student_activity_indicator  !=  'Active'
	and st.student_status != 'Enrolled'
--	and sch.reporting_school_ind = 'N'
	and adm_sd.local_school_year = '2014-2015'
--	and enr.withdraw_reason_code = 'HSC'
	AND (sch.school_key IN ('819', '2332', '724', '162', '425', '745', '178', '848', '997', '727', '747', '2334', '992', '2358', '773', '748', '708', '2312', '828', '709', '749', '750', '427', '751', '752', '428', '730', '2361', '972', '445', '180', '754', '850', '429', '756', '755', '161', '430', '757', '846', '758', '431', '710', '849', '2319', '759', '432', '762', '457', '763', '434', '765', '435', '767', '769', '770', '771', '772', '418', '438', '485', '439', '158', '775', '854', '776', '777', '441', '779', '712', '872', '520', '711', '780', '781', '782', '443', '783', '784', '853', '165', '785', '823', '786', '2333', '787', '788', '1210', '833', '790', '791', '793', '426', '713', '999', '824', '734', '141', '142', '456', '461', '885', '794', '795', '798', '706', '799', '800', '801', '802', '973', '803', '805', '806', '462', '437', '807', '976', '970', '843', '2313', '2318', '2294', '2359', '2316', '761', '433', '726', '451', '715', '744', '789', '768', '808', '931', '809', '419', '810', '718', '888', '811', '2335', '1000', '969', '864', '875', '4998', '450', '2336', '444', '2293', '815', '138', '463', '869', '717', '139', '5043', '446', '440', '720', '172', '422', '987', '968', '2314', '464', '820', '447', '821', '822', '448', '722', '862', '844', '2321', '990', '839', '858', '887', '876', '818', '764', '891', '449', '825', '829', '766', '2309', '830', '2315', '1206', '831', '2360', '835', '454', '723', '2337', '174', '971', '452', '797', '836', '837', '176', '269', '268', '868', '893', '455', '892', '975', '812'))
ORDER BY
	1,4
