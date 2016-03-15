SELECT pupil_number AS PUPIL_NUMBER, registration_date AS REGISTRATION_DATE,
       school AS SCHOOL,
       transaction_code AS TRANSACTION_CODE,
       indicator AS INDICATOR,
       long_name AS LONG_NAME,
       ministry_number AS MINISTRY_NUMBER
       FROM ( SELECT pupil_number, registration_date AS registration_date, r.school AS school,
              transaction_code AS transaction_code, 'R' AS indicator, long_name AS long_name,
              ministry_number AS ministry_number, r.create_date AS CREATE_DATE
              FROM registrations r, schools s
              where s.school = r.school
              UNION SELECT pupil_number, registration_date, r.school,
                           transaction_code, 'R', long_name, ministry_number,
                           r.create_date AS CREATE_DATE
                    FROM registrations_archive r, schools s
                    where s.school = r.school
              UNION SELECT pupil_number, effective_date, r.admit_school,
                    TO_CHAR(withdraw_code), 'W', long_name, ministry_number,
                    r.create_date
                    FROM admission_withdraw r, schools s
                    where s.school = r.admit_school
                      and admit_withdraw_ind = 'W'
              UNION SELECT pupil_number, effective_date, r.admit_school,
                    TO_CHAR(ADMISSION_CODE), 'A', long_name, ministry_number,
                    r.create_date AS CREATE_DATE
                    FROM admission_withdraw r, schools s
                    where s.school = r.admit_school
                      and admit_withdraw_ind = 'A'
              ORDER BY CREATE_DATE)
       WHERE pupil_number = 8031878 --:students.pupil_number
ORDER BY registration_date DESC
