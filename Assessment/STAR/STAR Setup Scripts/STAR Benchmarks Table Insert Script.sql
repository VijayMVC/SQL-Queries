--STAR Benchmarks
SPOOL K12INTEL_USERDATA.XTBL_TEST_BENCHMARKS.log
SET SERVEROUTPUT ON
SET ECHO ON

SELECT count(*) FROM K12INTEL_USERDATA.XTBL_TEST_BENCHMARKS;

INSERT INTO K12INTEL_USERDATA.XTBL_TEST_BENCHMARKS
(
SELECT
    tst.test_number
    ,case when tst.test_subject = 'Mathematics' then 'STAR Mathematics Benchmark - ' || tst.test_grade_group
          when tst.test_subject = 'Reading' then 'STAR Reading Benchmark - ' || tst.test_grade_group
          when tst.test_subject = 'Early Literacy' then 'STAR Early Literacy Benchmark - ' || tst.test_grade_group end as test_benchmark_type
    ,'--' as test_benchmark_group_code
    ,tst.test_grade_group as test_benchmark_group
    ,targets.code
    ,targets.text
    ,'--' as test_admin_period
    ,tst.test_subject
    ,tst.test_grade_group
    ,'--' as benchmark_scope_value
    ,'--' as benchmark_scope_value_2
    ,case when targets.code = '1' then 75
         when tst.test_subject in ('Reading', 'Early Literacy') and targets.code = '2' then 45
         when tst.test_subject = ('Mathematics') and targets.code = '2' then 55
         when targets.code = '3' then 26
         when targets.code = '4' then 11
         when targets.code = '5' then 0 end as min_value
    ,case when targets.code = '1' then 100
        when targets.code = '2' then 74
         when tst.test_subject in ('Reading', 'Early Literacy') and targets.code = '3' then 44
         when tst.test_subject = ('Mathematics') and targets.code = '3' then 54
         when targets.code = '4' then 25
         when targets.code = '5' then 10 end as max_value
    ,case when targets.code in ('1','2') then 'Yes' else 'No' end as passing_indicator
    ,to_date('07/01/2015','MM/DD/YYYY') as effective_start_date
    ,to_date('12/31/9999', 'MM/DD/YYYY') AS effective_end_date
    ,'3619' as district_code
    ,'--' as record_status
    ,sys_guid() as test_benchmark_uuid
    ,'WARDB' as mod_user
    ,sysdate as mod_date
FROM
    K12INTEL_USERDATA.XTBL_TESTS tst
    INNER JOIN 
        (SELECT 'Significantly Above Target' as text, '1' as code FROM DUAL
        UNION SELECT 'On Target', '2' FROM DUAL
        UNION SELECT 'Below Target', '3' FROM DUAL
        UNION SELECT 'Well Below Target', '4' FROM DUAL
        UNION SELECT 'Significantly Below Target', '5' FROM DUAL) targets on 1=1
WHERE
    tst.test_name like 'STAR%'
    and test_class = 'Component' 
    and tst.test_name = 'STAR Math'
    and (
        (tst.test_name = 'STAR Math' and TST.TEST_GRADE_GROUP in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11'))
        or (tst.test_name = 'STAR Reading' and TST.TEST_GRADE_GROUP in ('02', '03', '04', '05', '06', '07', '08', '09', '10', '11'))
        or (tst.test_name = 'STAR Early Literacy' and TST.TEST_GRADE_GROUP in ('K5', '01'))
        )  
)
;
SELECT count(*) FROM K12INTEL_USERDATA.XTBL_TEST_BENCHMARKS  --should have 240 more records
;
SELECT * FROM K12INTEL_DW.DTBL_TEST_BENCHMARKS WHERE TEST_BENCHMARK_TYPE LIKE 'STAR%' order by 3,4,5
;
select * from k12intel_dw.dtbl_tests where test_name like 'STAR%' order by test_subject, test_grade_group ;
commit;
SPOOL OFF