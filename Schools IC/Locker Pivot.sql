SELECT
	pvt.name,
	pvt.number,
	pvt.type,
	'Combo ' + convert(varchar,pvt.comboseq) as [current],
	pvt.[1] as combo1,
	pvt.[2] as combo2,
	pvt.[3] as combo3,
	pvt.[4] as combo4,
	pvt.[5] as combo5
FROM
(SELECT
	sch.name,
	lckr.number,
	lckr.type,
	lock.comboseq,
	lckrc.seq,
	lckrc.combo
FROM
	dbo.locker lckr 
	LEFT OUTER JOIN	dbo.LockerAssignment lckra on lckr.lockerid = lckra.lockerId
	INNER JOIN dbo.lock on lock.lockid = lckr.lockid
	INNER JOIN dbo.lockcombination lckrc on lckrc.lockid = lock.lockid
	INNER JOIN dbo.school sch on sch.schoolid = lckr.schoolid
WHERE
	sch.schoolid = 52
) lockers
PIVOT (max(lockers.combo) FOR lockers.seq in ([1],[2],[3],[4],[5])) as pvt
ORDER BY pvt.number