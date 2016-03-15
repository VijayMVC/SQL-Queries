SPOOL K12INTEL_DW.MPSD_STAR_TARGETS.log
SET SERVEROUTPUT ON
SET ECHO ON

DROP TABLE K12INTEL_DW.MPSD_STAR_TARGETS;
CREATE TABLE K12INTEL_DW.MPSD_STAR_TARGETS AS
(
select distinct
    b.test_subject AS SUBJECT
    ,case when b.test_grade_group = 'KG' then 'K5' else b.test_grade_group end as GRADE
    ,w.season
    ,w.school_year
    ,b.min_value AS TARGET_PERCENTILE
    ,'--' as target_score
FROM k12intel_dw.DTBL_TEST_BENCHMARKS B
inner join (select distinct season, school_year from k12intel_dw.mpsd_star_windows win) w on w.school_year = '2015-2016'
WHERE 1=1 
    and b.test_benchmark_type like 'STAR%'
    and b.test_benchmark_code = '2'
)
    
;
COMMIT;
SELECT * FROM k12intel_dw.mpsd_star_targets;

SPOOL OFF