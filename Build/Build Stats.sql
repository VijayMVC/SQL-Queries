SELECT 
    p.package_id,
    p.package_name,
    t.task_id,
    t.task_name,
    t.task_desc,
    t.task_resource_name,
    tL.build_number,
    tl.start_time,
    tl.end_time,
    TO_CHAR ( (tl.end_time - tl.start_time) * 24 * 60,
            '9999.999')
      AS minutes,
    TO_CHAR ( (SYSDATE - tl.start_time) * 24 * 60,
         '99999.999')
    AS net_minutes, 
    ex.status_name,
    ts.rows_processed,
    ts.rows_inserted,
    ts.rows_updated,
    ts.rows_deleted,
    ts.rows_evolved,
    ts.rows_audited,
    ts.dberr_count
 --   ,tp.*
--    ,aud.*
FROM
    K12INTEL_METADATA.WORKFLOW_PACKAGE p
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK t on p.package_uuid = t.package_uuid
--    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK_PARAM_VALUE tp on tp.task_uuid = t.task_uuid
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK_STATS ts on ts.task_id = t.task_id 
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK_LOG tl on tl.task_id = t.task_id and p.package_id = tl.package_id and ts.build_number = tl.build_number
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_EXECUTION_STATUS ex on ex.status_id = tl.execution_status_id
--    INNER JOIN K12INTEL_METADATA.WORKFLOW_DEPENDENCY dep on dep.package_uuid = p.package_uuid 
--    LEFT JOIN K12INTEL_AUDIT.RAW_AUDITS aud on aud.task_id = t.task_id and aud.package_id = p.package_id and aud.build_number = tl.build_number
WHERE 1=1 
    and p.package_name = 'BUILD K12INTEL' 
--    and tl.build_number = '8151'
--    and t.task_id in  (2012)
   AND tl.build_number = (SELECT MAX (build_number)    - :p_offset  
                        FROM k12intel_metadata.workflow_task_log)
--    and t.task_name like '%MV%'
--    and task_resource_name like 'FTBL_TEST_SCORES%'
--    and task_param_valueS like '%ODSADMIN.%'
--    and status_name = 'FAILURE'
--    and ts.dberr_count > 0
--    and aud.audit_source_location not in ('STUDENT_CATCHMENT_SCHOOL', 'STUDENT_COUNTRY_OF_CITIZENSHIP', 'STUDENT_NEXT_YEAR_SCHOOL_CODE')
--    AND AUD.AUDIT_SOURCE_LOCATION = 'STUDENT_ESL_INDICATOR'
ORDER BY
   t.task_id, 
   tl.end_time desc
 --    end_time - start_time
 
;
select * from k12intel_metadata.K12INTEL_ETL_PROCEDURES 