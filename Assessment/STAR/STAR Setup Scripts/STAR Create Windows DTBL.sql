SPOOL K12INTEL_DW.MPSD_STAR_WINDOWS.log
SET SERVEROUTPUT ON
SET ECHO ON

DROP TABLE K12INTEL_DW.MPSD_STAR_WINDOWS;
CREATE TABLE K12INTEL_DW.MPSD_STAR_WINDOWS
(
  SCHOOL_YEAR              VARCHAR2(9 BYTE),
  CALENDAR_TYPE            VARCHAR2(30 BYTE),
  SEASON                   VARCHAR2(20 BYTE),
  START_DATE               DATE,
  END_DATE                 DATE,
  BEGIN_CALENDAR_DATE_KEY  NUMBER,
  END_CALENDAR_DATE_KEY    NUMBER
)
TABLESPACE K12INTEL_DW_DATA
RESULT_CACHE (MODE DEFAULT)
PCTUSED    0
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          64K
            NEXT             1M
            MAXSIZE          UNLIMITED
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            BUFFER_POOL      DEFAULT
            FLASH_CACHE      DEFAULT
            CELL_FLASH_CACHE DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE
NOPARALLEL
MONITORING;
;
CREATE INDEX star_cal_winbeginkey_idx on K12INTEL_DW.MPSD_STAR_WINDOWS (begin_calendar_date_key) tablespace k12intel_dw_index;
CREATE INDEX star_cal_winendkey_idx on K12INTEL_DW.MPSD_STAR_WINDOWS (end_calendar_date_key) tablespace k12intel_dw_index;
CREATE INDEX star_cal_winbegin_idx on K12INTEL_DW.MPSD_STAR_WINDOWS (start_date) tablespace k12intel_dw_index;
CREATE INDEX star_cal_endbegin_idx on K12INTEL_DW.MPSD_STAR_WINDOWS (end_date) tablespace k12intel_dw_index;
;
COMMIT;

SELECT * FROM K12INTEL_DW.MPSD_STAR_WINDOWS;

INSERT ALL
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'Year-Round', 'Fall', to_date('08-10-2015','MM-DD-YYYY'), to_date('09-04-2015','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'IB', 'Fall', to_date('08-17-2015','MM-DD-YYYY'), to_date('09-11-2015','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'King/Reagan', 'Fall', to_date('08-17-2015','MM-DD-YYYY'), to_date('09-11-2015','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES      ('2015-2016', 'Traditional', 'Fall', to_date('09-14-2015','MM-DD-YYYY'), to_date('10-09-2015','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'Year-Round', 'Winter', to_date('01-04-2016','MM-DD-YYYY'), to_date('01-29-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'IB', 'Winter', to_date('01-04-2016','MM-DD-YYYY'), to_date('01-29-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'King/Reagan', 'Winter', to_date('01-04-2016','MM-DD-YYYY'), to_date('01-29-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES      ('2015-2016', 'Traditional', 'Winter', to_date('01-04-2016','MM-DD-YYYY'), to_date('01-29-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'Year-Round', 'Spring', to_date('05-02-2016','MM-DD-YYYY'), to_date('05-27-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'IB', 'Spring', to_date('05-02-2016','MM-DD-YYYY'), to_date('05-27-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'King/Reagan', 'Spring', to_date('05-02-2016','MM-DD-YYYY'), to_date('05-27-2016','MM-DD-YYYY'), null, null)
INTO k12INTEL_dw.mpsd_STAR_WINDOWS
VALUES ('2015-2016', 'Traditional', 'Spring', to_date('05-02-2016','MM-DD-YYYY'), to_date('05-27-2016','MM-DD-YYYY'), null, null)
SELECT * FROM DUAL
;
SELECT * FROM K12INTEL_DW.MPSD_STAR_WINDOWS;

UPDATE K12INTEL_DW.MPSD_STAR_WINDOWS s
SET s.BEGIN_CALENDAR_DATE_KEY = (select cd.calendar_date_key
                                from k12intel_dw.dtbl_calendar_dates cd
                                where cd.date_value = S.START_DATE)
;
UPDATE K12INTEL_DW.MPSD_STAR_WINDOWS s
SET s.end_CALENDAR_DATE_KEY = (select cd.calendar_date_key
                                from k12intel_dw.dtbl_calendar_dates cd
                                where cd.date_value = S.end_DATE)
;                                 
analyze table K12INTEL_DW.MPSD_STAR_WINDOWS compute statistics;

commit;

SPOOL OFF