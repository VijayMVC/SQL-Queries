SELECT
    st.student_key,
    st.student_current_school_code as "School Code",
    st.STUDENT_current_school as "School Name",
    schx.group2 as "Region",
    st.student_id as "ID",
 	st.student_name as "Name",
	st.student_race as "Race",
	st.student_gender_code as "Gender",
	st.student_foodservice_indicator as "Econ Disadv",
	st.student_special_ed_indicator as "SwD",
	st.student_esl_indicator as "ELL",
 	ST.STUDENT_current_grade_code as "Current Grade",

--Attendance
    attd.membership_days as "2014-15 Membership Days",
   -- attd_2013.absence_days as ytd_2013_absence_days,
    attd.attendance_percentage as "2014-15 Attendance Rate",

--MAP reading and Foundational Literacy Strand
	case when map_fall_1415.test_primary_result_code is not NULL then map_fall_1415.test_primary_result_code
        else '6' end as "Reading Performance Level Code",
    case when map_fall_1415.test_primary_result is not NULL then map_fall_1415.test_primary_result
        else 'Untested' end as "Reading Performance Level",
    map_fall_1415.rit_score as "Reading RIT",
--MAP strand
    map_fall_1415_strand.test_primary_result as  "Foundational Literacy Strand",

--PALS score
   case when pals_fall_1415.test_secondary_result_code = 1 then 'Spanish PALS'
        when pals_fall_1415.test_secondary_result_code = 0 then 'English PALS' else 'No PALS Test' end as "PALS Test Type",
   pals_fall_1415.spelling_result as "PALS Spelling Result",
   pals_fall_1415.spelling_score as "PALS Spelling Score",
   pals_fall_1415.spelling_benchmark as "PALS Spelling Benchmark",
   pals_fall_1415.letters_result as "PALS Letter Sounds Result",
   pals_fall_1415.letters_score as "PALS Letter Sounds Score",
   pals_fall_1415.letters_benchmark as "PALS Letter Sounds Benchmark",
   case when pals_fall_1415.test_student_grade = 'K5' then pals_fall_1415.alphabet_result else pals_fall_1415.word_list_preprimer_result end as "PALS Alph/Word Rec Result",
   case when pals_fall_1415.test_student_grade = 'K5' then pals_fall_1415.alphabet_score else pals_fall_1415.word_list_preprimer_score end as "PALS Alph/Word Rec Score",
   case when pals_fall_1415.test_student_grade = 'K5' then pals_fall_1415.alphabet_benchmark else pals_fall_1415.word_list_preprimer_benchmark end as "PALS Alph/Word Rec Benchmark",
   pals_fall_1415.rhyme_result as "K5 Rhyme Awareness Result",
   pals_fall_1415.rhyme_score as "K5 Rhyme Awareness Score",
   pals_fall_1415.rhyme_benchmark as "K5 Rhyme Awareness Benchmark",
   pals_fall_1415.beginning_sounds_result as "K5 Beginning Sounds Result",
   pals_fall_1415.beginning_sounds_score as "K5 Beginning Sounds Score",
   pals_fall_1415.beginning_sounds_benchmark as "K5 Beginning Sounds Benchmark",
   pals_fall_1415.concept_result as "K5 Concept of Word Result",
   pals_fall_1415.concept_score as "K5 Concept of Word Score",
   pals_fall_1415.concept_benchmark as "K5 Concept of Word Benchmark",
   case when pals_fall_1415.test_student_grade = 'K5' then pals_fall_1415.summed_K5_result else pals_fall_1415.summed_1_2_result end as "PALS Summed Result",
   case when pals_fall_1415.test_student_grade = 'K5' then pals_fall_1415.summed_K5_score else pals_fall_1415.summed_1_2_score end as "PALS Summed Score",
   case when pals_fall_1415.test_student_grade = 'K5' then pals_fall_1415.summed_K5_benchmark else pals_fall_1415.summed_1_2_benchmark end as "PALS Summed Benchmark" ,

--ACT Scores
   act.english_scale as "Aspire English Scale Score",
   act.english_ready as "Aspire English Readiness",
   act.english_llevel as "Aspire English Level",
   act.math_scale as "Aspire English Scale Score",
   act.math_ready as "Aspire English Readiness",
   act.math_level as "Aspire English Level",
   act.read_scale as "Aspire Reading Scale Score",
   act.read_ready as "Aspire Reading Readiness",
   act.read_level as "Aspire Reading Level",
   act.sci_scale as "Aspire Science Scale Score",
   act.sci_ready as "Aspire Science Readiness",
   act.sci_level as "Aspire Science Level",
   act.stem_ready as "Aspire STEM Readiness",
   act.ela_ready as "Aspire ELA Readiness"

FROM
	K12INTEL_DW.DTBL_STUDENTS st
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_code = st.student_current_school_code
    INNER JOIN K12INTEL_DW.DTBL_SCHOOLS_EXTENSION schx on schx.school_key = sch.school_Key
	LEFT OUTER JOIN
		( select
				a.student_key,
			 	sum(a.attend_days)  as membership_days,
			   -- sum(a.attend_days - a.attend_value)  as absence_days,
			    round( (sum(a.attend_value)   /   sum(a.attend_days) ) ,3) as attendance_percentage
			 from
			  		K12INTEL_DW.MPS_MV_ATTEND_YTD_SCHSTU a
			 WHERE
			       a.local_school_year = '2014-2015'
			 group by
		 	a.student_key) attd on st.student_key = attd.student_key

	LEFT OUTER JOIN
		( SELECT
			f.student_key,
            t.test_class,
            f.test_primary_result_code,
            f.test_primary_result,
			f.TEST_SCALED_SCORE as rit_score
		FROM
	  		K12INTEL_DW.FTBL_TEST_SCORES F
	  		INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
	  		INNER JOIN	k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
	  		inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
		WHERE
			T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and T.TEST_CLASS  =  'COMPONENT'
	    	AND    sd.local_school_year= '2014-2015'
	    	 )  map_fall_1415 on map_fall_1415.student_key = st.student_key
	LEFT OUTER JOIN
        ( SELECT
            f.student_key,
            t.test_class,
            f.test_primary_result_code,
            f.test_primary_result
        FROM
              K12INTEL_DW.FTBL_TEST_SCORES F
              INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
              INNER JOIN    k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
              inner join k12intel_dw.dtbl_students st on f.student_key = st.student_key
        WHERE
            T.TEST_TYPE = 'MAP SCREENER'  and  T.TEST_SUBJECT = 'Reading' and
            (T.TEST_CLASS = 'STRAND' and t.courses_subject in ('Foundational Skills', 'Foundational Skills and Vocabulary'))
            AND    sd.local_school_year= '2014-2015'
             )  map_fall_1415_strand on map_fall_1415_strand.student_key = st.student_key
    LEFT OUTER JOIN
	(SELECT *
        FROM
            (SELECT
            f.student_key,
            f.test_student_grade,
            t.test_subgroup,
            f.test_secondary_result_code,
            f.test_primary_result_code,
            f.test_primary_result,
            f.test_scaled_score as benchmark,
            f.test_score_value as score
        FROM
              K12INTEL_DW.FTBL_TEST_SCORES F
              INNER JOIN K12INTEL_DW.dtbl_TESTs T on F.TESTS_KEY = T.TESTS_KEY
              INNER JOIN    k12intel_dw.dtbl_school_dates  sd ON f.school_dates_key = sd.school_dates_key
        WHERE 1=1
            and t.test_type = 'PALS'
            and t.test_class = 'COMPONENT'
            and f.test_admin_period = 'Fall'
            and sd.local_school_year = '2014-2015'
            and ((
             f.TEST_STUDENT_GRADE  =  'K5'
             and t.TEST_SUBJECT  IN  ( 'Alphabet Recognition: Lowercase','Beginning Sound Awareness: Group','Letter Sounds','Spelling','Rhyme Awareness: Group','Concept of Word: Word List','Summed Score'  )
            )
            OR
            ( f.TEST_STUDENT_GRADE  =  '01'
             and t.TEST_SUBJECT  IN  ( 'Summed Score: Entry Level','Spelling','Word List: Preprimer','Word List: First Grade','Letter Sounds') --,'Oral Reading in Context'  )
              )
            OR
            ( f.TEST_STUDENT_GRADE  =  '02'
             AND t.TEST_SUBJECT  IN  ( 'Summed Score: Entry Level','Spelling','Word List: First Grade') --'Oral Reading in Context'  )
            )) )  pals
 PIVOT
    (max(test_primary_result_code) as result_code,
    max(test_primary_result) as result,
    max(score) as score,
    max(benchmark) as benchmark
    FOR test_subgroup in (
                            'Rhyme Awareness: Group' as rhyme,
                            'Beginning Sound Awareness: Group' as beginning_sounds,
                            'Alphabet Recognition: Lowercase' AS alphabet,
                                'Letter Sounds' as letters,
                               'Spelling' as spelling,
                              'Concept of Word: Word List' as concept,
                               'Summed Score' as summed_k5,
                              'Word List: Preprimer' as word_list_preprimer,
                                'Word List: First Grade' as word_list,
                                'Summed Score: Entry Level' as summed_1_2))) pals_fall_1415 on st.student_key = pals_fall_1415.student_key

    LEFT OUTER JOIN
    (SELECT * FROM K12INTEL_STAGING.TEMP_BLAKE) act on act.id = st.student_id
WHERE 1=1
	--and st.student_id in ('8514427')
    and st.student_activity_indicator = 'Active'
    and st.student_status = 'Enrolled'
    and sch.school_code in ( '73',
'90',
'41',
'81',
'92',
'94',
'678',
'104',
'116',
'119',
'122',
'125',
'143',
'148',
'150',
'170',
'173',
'179',
'185',
'191',
'192',
'193',
'196',
'205',
'208',
'211',
'214',
'428',
'218',
'224',
'337',
'672',
'250',
'256',
'265',
'267',
'667',
'71',
'274',
'277',
'283',
'289',
'301',
'313',
'194',
'29',
'318',
'322',
'325',
'312',
'343',
'344',
'368',
'387',
'390',
'85',
'295')
