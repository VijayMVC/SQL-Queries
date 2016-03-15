SELECT
    sch.school_name,
    coh.cohort_name,
    subject,
     Dsort  AS "C7144",
     Grade AS "C7145",
     Fall AS "C7147",
     Winter AS "C7148",
     Spring AS "C7149",
     case when Fall >= 0 and Winter >= 0 then 'No Gap' else cast (round(Winter - Fall,1) as varchar(6)) end AS "C7150",
     case when Winter >= 0 and Fall >= 0 then 'No Gap'
               when Fall = 0 and Winter < 0 then round((Winter-Fall) * -100,1)||'%'
               when Fall > 0 and Winter < 0 then round (((Winter-Fall)/Fall) * -100,1)||'%'
                else  round(((Winter-Fall)/Fall) * 100,1)||'%' end  AS "C7151",
     case when Fall >= 0 and Spring >= 0 then 'No Gap' else cast (round(Spring - Fall,1) as varchar(6)) end AS "C7152",
     case when Spring >= 0 and Fall >= 0 then 'No Gap'
                when Fall = 0 and Spring < 0 then round((Spring-Fall) * -100,1)||'%'
                when Fall > 0 and Spring < 0 then round (((Spring-Fall)/Fall) * -100,1)||'%'
                 else  round(((Spring-Fall)/Fall) * 100,1)||'%' end AS "C7153"
FROM
    K12INTEL_DW.DTBL_SCHOOLS sch
    LEFT OUTER JOIN K12INTEL_DW.DTBL_SCHOOL_COHORT_MEMBERS coh on coh.school_key = sch.school_Key
    INNER JOIN 
     (SELECT
              school_key
              ,grade
              ,subject
              ,avg(case when season = 'Fall' then gap else null end) as Fall
              ,avg(case when season = 'Winter' then gap else null end) as Winter
              ,avg(case when season = 'Spring' then gap else null end) as Spring
              ,case when grade in ('KG', 'K5') then 0 else 1 end as Dsort
          FROM
          (SELECT
              school.Season
              ,school.school_key
              ,school.grade
              ,school.school_year
              ,school.subject
              ,school.avg_percentile
              ,school.target_percentile
              ,school.avg_percentile - school.target_percentile as gap
          FROM
              (SELECT sc.season, sc.school_key, sc.school_year, sc.grade, sc.subject, avg(sc.test_percentile_score) as avg_percentile, avg(sc.target_percentile) as target_percentile
              FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES sc
                  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on sc.student_annual_attribs_key = dtbl_student_annual_attribs.student_annual_attribs_key
              WHERE 1=1
                        and ((sc.subject = 'Reading' and sc.test_student_grade in ('02','03','04','05','06','07','08','09','10','11'))
                    or (sc.subject = 'Mathematics' and sc.test_student_grade in ('01','02','03','04','05','06','07','08','09','10','11'))
                    or (sc.subject = 'Early Literacy' and sc.test_student_grade in ('K5','01')))
                    and sc.In_Window = 'Yes'
                    and sc.Attempt = 1
                  AND (sc.school_key IN ('759'))      
              GROUP BY sc.season, sc.school_key, sc.school_year, sc.grade, sc.subject
              UNION
              SELECT sc.season, sc.school_key, sc.school_year, 'Total' as grade, sc.subject, avg(sc.test_percentile_score) as avg_percentile, avg(sc.target_percentile) as target_percentile
              FROM K12INTEL_DW.MPS_MV_STAR_COMPONENT_SCORES sc
                  INNER JOIN K12INTEL_DW.DTBL_STUDENT_ANNUAL_ATTRIBS on sc.student_annual_attribs_key = dtbl_student_annual_attribs.student_annual_attribs_key
              WHERE 1=1
                   and ((sc.subject = 'Reading' and sc.test_student_grade in ('02','03','04','05','06','07','08','09','10','11')) 
                              or (sc.subject = 'Mathematics' and sc.test_student_grade in ('01','02','03','04','05','06','07','08','09','10','11')) 
                              or (sc.subject = 'Early Literacy' and sc.test_student_grade in ('K5','01'))) 
                   and sc.In_Window = 'Yes'
                    and sc.Attempt = 1
                  AND (sc.school_key IN ('759'))  
              GROUP BY sc.season, sc.school_key, sc.school_year, sc.subject
                   ) school    
             WHERE 1=1
                      and school.SUBJECT IN ('Reading')
                     and school.SCHOOL_YEAR IN ('2015-2016')
                  ) 
          GROUP BY
                grade, school_key, subject
          ) gap on gap.school_key = sch.school_Key
ORDER BY
     Dsort,
     Grade
