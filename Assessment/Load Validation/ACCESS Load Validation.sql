select * from k12intel_userdata.xtbl_test_admin where 1=1  and prod_test_id like 'WIDA%'
and sys_record_stage = 'NOT VALIDATED'
;
select * from k12intel_dw.dtbl_tests where test_vendor = 'WIDA' or test_type like 'ACCESS%';
;
select max(tl.build_number)
FROM
    K12INTEL_METADATA.WORKFLOW_PACKAGE p
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK t on p.package_uuid = t.package_uuid

    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK_STATS ts on ts.task_id = t.task_id 
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK_LOG tl on tl.task_id = t.task_id and p.package_id = tl.package_id and ts.build_number = tl.build_number
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_EXECUTION_STATUS ex on ex.status_id = tl.execution_status_id
--    LEFT JOIN K12INTEL_AUDIT.RAW_AUDITS aud on aud.task_id = t.task_id and aud.package_id = p.package_id and aud.build_number = tl.build_number
WHERE 1=1 
    and p.package_name = 'BUILD K12INTEL' 
--    and tl.build_number = '8172'
--   AND tl.build_number = (SELECT MAX (build_number)    - :p_offset  
--                        FROM k12intel_metadata.workflow_task_log)
    and task_resource_name like 'FTBL_TEST_SCORES%'
;
SELECT
    xa.test_admin_key
    ,xa.batch_id
    ,xa.prod_test_id
    ,xa.state_student_id
    ,xa.district_student_id
    ,xa.state_school_id
    ,xa.student_first_name
    ,xa.student_last_Name 
    ,xa.student_birthdate_str
    ,xa.test_admin_date_str
    ,xa.test_student_grade
    ,tst.test_number
    ,tst.test_name
    ,TST.TEST_CLASS
    ,tst.test_subject
    ,xs.test_primary_result_code
    ,xs.test_primary_result
    ,xs.test_secondary_result_code
    ,xs.test_secondary_result
    ,xs.test_score_value
    ,aud.*
FROM 
    k12intel_userdata.xtbl_test_admin xa
    INNER JOIN K12INTEL_USERDATA.XTBL_TEST_SCORES xs on xs.test_admin_key = xa.test_admin_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.test_number = xs.test_number
    INNER JOIN K12INTEL_AUDIT.RAW_AUDITS aud on REGEXP_SUBSTR(aud.audit_data_lineage,'\d+',1,1) = to_char(xa.test_admin_key)
                                           --  and REGEXP_SUBSTR(aud.audit_data_lineage,'\d+',1,1) = to_char(xa.batch_id)
WHERE
    prod_test_id like 'WIDA%'
    and sys_record_stage = 'NOT VALIDATED'
 --   and xa.test_admin_key = 450488
    and aud.build_number = 8175
 ;
 
 SELECT distinct
    xa.test_admin_key
    ,xa.district_student_id
    ,xa.state_student_id
    ,xa.state_school_id
    ,aud.audit_source_location
    ,aud.audit_base_msg
FROM 
    k12intel_userdata.xtbl_test_admin xa
    INNER JOIN K12INTEL_USERDATA.XTBL_TEST_SCORES xs on xs.test_admin_key = xa.test_admin_key
    INNER JOIN K12INTEL_DW.DTBL_TESTS tst on tst.test_number = xs.test_number
    INNER JOIN K12INTEL_AUDIT.RAW_AUDITS aud on REGEXP_SUBSTR(aud.audit_data_lineage,'\d+',1,1) = to_char(xa.test_admin_key)
                                           --  and REGEXP_SUBSTR(aud.audit_data_lineage,'\d+',1,1) = to_char(xa.batch_id)
WHERE
    prod_test_id like 'BADGER%'
    and sys_record_stage = 'NOT VALIDATED'
 --   and xa.test_admin_key = 450488
    and aud.build_number = 8173