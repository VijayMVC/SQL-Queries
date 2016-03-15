SET SERVEROUTPUT ON
SET ECHO OFF
--SET TRIMSPOOL ON --PAGESIZE 0 LINESIZE 500
SPOOL c:/users/wardb/logs/aspire_test.log

--SELECT TO_CHAR(SYSDATE, 'YYYY-mm-dd HH24:MI:SS') "Timestamp" FROM DUAL;

DECLARE
   v_row_cnt          NUMBER := 0;
   v_ins_cnt          NUMBER := 0;
   v_err_cnt          NUMBER := 0;
   v_rd_cnt           NUMBER := 0;
   v_skip_cnt         NUMBER := 0;
   v_skip_flag        NUMBER := 0;
   v_upd_count     NUMBER := 0;
   v_eight_sch_code   VARCHAR2 (10) := ' ';
   v_eight_sch        VARCHAR2 (50) := ' ';
   v_max_eight_year       VARCHAR2 (9) := ' ';
   v_schl_year        VARCHAR2 (9) := '2014-2015';
    
   CURSOR cur IS SELECT * FROM K12INTEL_STAGING.TEMP_BLAKE WHERE ROWNUM < 1000;

   --Loop through Aspire scores
BEGIN
   FOR vrow IN cur
   LOOP
      v_rd_cnt := v_rd_cnt + 1;      --Count the records processed in the loop
      v_skip_flag := 0;
   --Set Eighth Grade School
       BEGIN
          SELECT max(school_year)
            INTO v_max_eight_year
            FROM k12intel_dw.dtbl_student_annual_attribs staa
           WHERE staa.student_id = vrow.id
                and staa.student_annual_grade_code = '08';
            v_upd_count := v_upd_count + 1;
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             v_skip_cnt     :=   v_skip_cnt + 1;
             v_skip_flag    := 1;
          WHEN OTHERS
          THEN
             v_skip_cnt     :=   v_skip_cnt + 1;
             v_skip_flag    := 1;
       END;
--   
--       BEGIN
--          SELECT sch.school_code
--            INTO v_eight_sch_code
--            FROM k12intel_dw.dtbl_student_annual_attribs aa INNER JOIN K12INTEL_DW.DTBL_SCHOOLS sch on sch.school_Key = aa.school_key
--           WHERE student_id = vrow.student_id
--                and aa.school_year = v_max_eight_year;
--       EXCEPTION
--          WHEN OTHERS
--          THEN
--             v_skip_cnt     :=   v_skip_cnt + 1;
--             v_skip_flag    := 1;
--       END;
--   
--       BEGIN
--          SELECT school_name
--            INTO v_eight_sch
--            FROM K12INTEL_DW.DTBL_SCHOOLS
--           WHERE school_code = v_eight_sch_code;
--       EXCEPTION
--          WHEN OTHERS
--          THEN
--             v_skip_cnt     :=   v_skip_cnt + 1;
--             v_skip_flag    := 1;
--       END;
--    
--      BEGIN
--        UPDATE K12INTEL_STAGING.TEMP_BLAKE
--            SET eight_school_code = v_eight_sch_code, eight_school_name = v_eight_sch
--        WHERE student_id = vrow.student_id;
--      END;  
      
   END LOOP;
COMMIT;
DBMS_OUTPUT.put_line ('total cursor staging rows read=' || v_rd_cnt);
DBMS_OUTPUT.put_line ('total cursor staging rows updated=' || v_upd_count);
DBMS_OUTPUT.put_line ('total cursor staging rows skipped=' || v_skip_cnt);

END;    
 
   