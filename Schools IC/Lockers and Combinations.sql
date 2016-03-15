DECLARE
	@schoolid int

SET
	@schoolid = 52

SELECT
	sch.name,
	lckr.number,
	lckr.type,
	lock.comboseq as [current],
	max(case when lckrc.seq = 1 then lckrc.combo end) as combo1,
	max(case when lckrc.seq = 2 then lckrc.combo end) as combo2,
	max(case when lckrc.seq = 3 then lckrc.combo end) as combo3,
	max(case when lckrc.seq = 4 then lckrc.combo end) as combo4,
	max(case when lckrc.seq = 5 then lckrc.combo end) as combo5,
	max(case when lckrc.seq = 6 then lckrc.combo end) as combo6
FROM
	dbo.LockerAssignment lckra
	INNER JOIN dbo.locker lckr on lckr.lockerid = lckra.lockerId
	INNER JOIN dbo.lock on lock.lockid = lckr.lockid
	INNER JOIN dbo.lockcombination lckrc on lckrc.lockid = lock.lockid
	INNER JOIN dbo.school sch on sch.schoolid = lckr.schoolid
	INNER JOIN dbo.lockerlocation lckrl on lckrl.schoolid = sch.schoolid
	INNER JOIN dbo.person per on per.personid = lckra.personid
WHERE
	sch.schoolid = @schoolid
GROUP BY
	sch.name,
	sch.schoolid,
	lckr.number,
	lckr.type,
	lock.comboseq