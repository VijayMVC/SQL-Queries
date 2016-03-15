select * from k12intel_dw.dtbl_test_benchmarks
;
create table k12intel_dw.mpsd_star_targets
as (select * from k12intel_dw.mpsd_district_map_targets)
;
alter table k12intel_dw.mpsd_star_targets
rename column target_rit_score to target_score

;
truncate table k12intel_dw.mpsd_star_targets;
commit;

drop table temp_star_targets;
rollback;

select * from temp_star_targets;