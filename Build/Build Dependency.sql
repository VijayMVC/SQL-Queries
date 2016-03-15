--Child view

SELECT 
    p.package_id,
    p.package_name,
    tch.task_id,
    tch.task_name as child_task,
    tch.task_resource_name as child_resc,
    tsch.build_number,  
    tlch.start_time as child_start,
    tlch.end_time as child_end,
    exch.status_name as child_status,
    d.dependency_critical_ind,
    tp.task_name as parent_task,
    tlp.start_time as parent_start,
    tlp.end_time as parent_end,
    expar.status_name as parent_status
FROM
    K12INTEL_METADATA.WORKFLOW_PACKAGE p
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK tch on p.package_uuid = tch.package_uuid --and d.task_uuid_child = tch.task_uuid
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_STATS tsch on tsch.task_id = tch.task_id and tsch.build_number = '8121'
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_LOG tlch on tlch.task_id = tch.task_id and tlch.build_number = tsch.build_number
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_EXECUTION_STATUS exch on exch.status_id = tlch.execution_status_id
--add dependencies
    INNER JOIN K12INTEL_METADATA.WORKFLOW_DEPENDENCY d on d.package_uuid = p.package_uuid and d.task_uuid_child = tch.task_uuid
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK tp on tp.task_uuid = d.task_uuid_parent
--add parent stats
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_STATS tsp on tsp.build_number = tsch.build_number and tsp.task_id = tp.task_id
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_LOG tlp on tlp.task_id = tsp.task_id and tlp.build_number = tsp.build_number
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_EXECUTION_STATUS expar on expar.status_id = tlp.execution_status_id 
WHERE 1=1 
    and p.package_name = 'BUILD K12INTEL' 
    and tch.task_id = '2022'
ORDER BY 
    tch.task_id
 --    tlch.start_time
--     end_time - start_time

;

--Parent view

SELECT 
    p.package_id,
    p.package_name,
    tp.task_id,
    tp.task_name as parent_task,
    tsch.build_number, 
    tlp.start_time as parent_start,
    tlp.end_time as parent_end,
    expar.status_name as parent_status,
    d.dependency_critical_ind,
    tch.task_id,
    tch.task_name as child_task,
    tch.task_resource_name as child_resc,
    tlch.start_time as child_start,
    tlch.end_time as child_end,
    exch.status_name as child_status
FROM
    K12INTEL_METADATA.WORKFLOW_PACKAGE p
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK tp on p.package_uuid = tp.package_uuid
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_STATS tsp on tsp.task_id = tp.task_id and tsp.build_number = '8136'
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_LOG tlp on tlp.task_id = tsp.task_id and tlp.build_number = tsp.build_number
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_EXECUTION_STATUS expar on expar.status_id = tlp.execution_status_id 
--add dependencies
    INNER JOIN K12INTEL_METADATA.WORKFLOW_DEPENDENCY d on d.package_uuid = p.package_uuid and d.task_uuid_parent = tp.task_uuid
    INNER JOIN K12INTEL_METADATA.WORKFLOW_TASK tch on tch.task_uuid = d.task_uuid_child

--add child stats
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_STATS tsch on tsch.task_id = tch.task_id and tsp.build_number = tsch.build_number 
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_TASK_LOG tlch on tlch.task_id = tch.task_id and tlch.build_number = tsch.build_number
    LEFT JOIN K12INTEL_METADATA.WORKFLOW_EXECUTION_STATUS exch on exch.status_id = tlch.execution_status_id

WHERE 1=1 
    and p.package_name = 'BUILD K12INTEL' 
--    and tp.task_resource_name like  'FTBL_PROGR%'
    and tp.task_id = '19'
ORDER BY 
    tp.task_id
 --    tlch.start_time
--     end_time - start_time
 