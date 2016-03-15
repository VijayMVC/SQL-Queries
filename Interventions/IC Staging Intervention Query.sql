SELECT 
    st.personid
    ,st.studentnumber
    ,stid.firstName
    ,stid.lastName
    ,pt.contentarea
    ,pt.interventionTier
    ,pt.abbreviation
    ,pl.startdate as plan_start_date
    ,pl.enddate as plan_end_date
    --,pl.createdDate
    ,ps.name as service_name
    ,ps.description as service_desc
    ,ps.active
    ,pg.goalid
    ,pg.name as goal
    ,pg.baseScore
    ,pg.goalScore
    ,pg.assessmentCriteria
    --,psp.servicefrequency as freq
    --,psp.serviceFreqPeriod as freq_period
    --,psp.servicedirect as minutes
    --,psp.startDate as service_start_date
    --,psp.enddate as service_end_date
    ,intd.assessmentdate as intervention_date
    ,intd.score as intervention_score
FROM
    K12INTEL_STAGING_IC.Plan pl
    INNER JOIN K12INTEL_STAGING_IC.plantype pt on pt.typeid = pl.typeID and pl.stage_deleteflag = 0 and pl.stage_source = pt.stage_source
    INNER JOIN K12INTEL_STAGING_IC.PlanServiceProvided psp on psp.planid = pl.planid  and psp.stage_deleteflag = 0 and psp.stage_source = pl.stage_source and psp.stage_sis_school_year = pl.stage_sis_school_year
    INNER JOIN K12INTEL_STAGING_IC.planservice ps on ps.serviceid = psp.serviceid and psp.planid = pl.planid and ps.stage_deleteflag = 0 and ps.stage_source = pl.stage_source --and ps.stage_sis_school_year = pl.stage_sis_school_year
    INNER JOIN K12INTEL_STAGING_IC.plangoal pg on pg.planid = pl.planID and pg.stage_source = pl.stage_source
    INNER JOIN K12INTEL_STAGING_IC.person st on st.personid = pl.personid and st.stage_source = pl.stage_source
    INNER JOIN K12INTEL_STAGING_IC.Identity stid on stid.identityID = st.currentIdentityID and stid.stage_deleteflag = 0 and stid.stage_sis_school_year = pl.stage_sis_school_year
    LEFT JOIN K12INTEL_STAGING_IC.InterventionDelivery intd on intd.goalid = pg.goalid and intd.stage_source = pl.stage_source 
WHERE 1=1
    and pt.contentarea in ('Behavior', 'Attendance', 'Academic')
    --and st.studentnumber = '8836234'
ORDER BY
    1,intd.assessmentdate
    ;