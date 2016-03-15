--STAR test admin

INSERT INTO K12INTEL_DW.MPSD_TEST_ADMIN_NUMBER
VALUES ('2015-2016', 'Fall', 'STAR', 0, sysdate)
;
Select * from k12intel_dw.mpsd_test_admin_number
where test_type = 'STAR'
; 
commit;