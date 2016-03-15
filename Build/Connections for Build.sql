SELECT
    p.package_id,
    p.package_name,
    pp.package_param_uuid,
    pp.package_param_name,
    pp.package_param_prompt,
    pp.package_param_value  
FROM
    K12INTEL_METADATA.WORKFLOW_PACKAGE p
    INNER JOIN K12INTEL_METADATA.WORKFLOW_PACKAGE_PARAM pp on pp.package_uuid = p.package_uuid
WHERE 
    p.package_name = 'BUILD K12INTEL' 
ORDER BY 
    pp.package_param_name
;
--Dev Target Lookup
SELECT
    p.package_id,
    p.package_name,
    pp.package_param_uuid,
    pp.package_param_name,
    pp.package_param_prompt,
    pp.package_param_value  
FROM
    K12INTEL_METADATA.WORKFLOW_PACKAGE p
    INNER JOIN K12INTEL_METADATA.WORKFLOW_PACKAGE_PARAM pp on pp.package_uuid = p.package_uuid
WHERE 
    p.package_name = 'BUILD K12INTEL' 
    and pp.package_param_uuid in 
    ('F85AB01FFC20279DE0431664140AB233',
    'F85AB01FFC28279DE0431664140AB233',
    '67CA7AE1-49BE-4253-8AEF-A2A396D16807',
    'F85AB01FFC2C279DE0431664140AB233',
    'F85AB01FFC30279DE0431664140AB233',
    'F85AB01FFC38279DE0431664140AB233',
    '2C6BE5BC-87CF-4176-A53C-25ABB4C26426')
ORDER BY 
    pp.package_param_name
;
--Dev Target update
UPDATE k12intel_metadata.workflow_package_param 
set package_param_value = 
'jdbc:oracle:thin:@ex02dbadm02.milwaukee.k12.wi.us:1521/RUNDWDEVIC.world'
where package_param_uuid in 
    ('F85AB01FFC20279DE0431664140AB233',
    'F85AB01FFC28279DE0431664140AB233',
    '67CA7AE1-49BE-4253-8AEF-A2A396D16807',
    'F85AB01FFC2C279DE0431664140AB233',
    'F85AB01FFC30279DE0431664140AB233',
    'F85AB01FFC38279DE0431664140AB233',
    '2C6BE5BC-87CF-4176-A53C-25ABB4C26426')
;    
commit;

--Update Passwords Entity
UPDATE k12intel_metadata.workflow_package_param 
set package_param_value = 
'javelin1912'
where package_param_uuid in 
    ('F85AB01FFC1D279DE0431664140AB233')
    ;

--Update IC Stage Source
UPDATE K12INTEL_METADATA.WORKFLOW_PACKAGE_PARAM
SET PACKAGE_PARAM_VALUE = 
'jdbc:sqlserver://ICMSSQL1.district.MPSDS.edu;instanceName=i1;databaseName=milwaukee'
WHERE PACKAGE_PARAM_UUID = '58F9D19F-EECB-40E9-AB0D-2D8BA813AC69'
;
commit;
