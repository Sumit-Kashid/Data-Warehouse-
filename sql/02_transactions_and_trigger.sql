-- KO_MED Hospital database: transactions and trigger
-- Author: Sumit Kashid
-- Inserts a patient across all tables, updates a bed assignment, and adds a
-- trigger that blocks assigning a bed that is already occupied.

USE KO_MED_Hospital;
GO

-- TASK 1: INSERT A NEW PATIENT ACROSS ALL TABLES

-- STEP 1A: Insert new PCP for the new patient (if not exists)

INSERT INTO PCP VALUES 
('PCP006', 'Dr. Susan Taylor', '112 Walnut Ave, Cincinnati OH 45206', '513-555-1006');

GO

-- STEP 1B: Insert the new PATIENT record
INSERT INTO PATIENT VALUES 
(
    'P1009',            -- PatientNumber
    'Edward',           -- FirstName
    'Collins',          -- LastName
    'M',                -- Gender
    '1947-08-15',       -- DateOfBirth (aged 60+)
    'Married',          -- MaritalStatus
    '99 Willow Lane, Cincinnati OH 45206', -- Address
    '513-555-3009',     -- Telephone
    'BlueCross',        -- InsuranceProvider
    'BC900901',         -- InsuranceNumber
    '2015-10-05',       -- DateRegistered
    'PCP006'            -- PracticeNumber (FK)
);

GO

-- STEP 1C: Insert APPOINTMENT for the new patient
INSERT INTO APPOINTMENT VALUES 
(
    'APT009',           -- AppointmentNumber
    '2015-10-06',       -- AppointmentDate
    '10:00:00',         -- AppointmentTime
    'Room 6',           -- ExaminationRoomNumber
    'P1009',            -- PatientNumber (FK)
    'N002'              -- StaffNumber (FK)
);

GO

-- STEP 1D: Insert INPATIENT record for the new patient
INSERT INTO INPATIENT VALUES 
(
    'IP007',            -- InpatientID
    'P1009',            -- PatientNumber (FK)
    'B03',              -- BedNumber (FK)
    'W01',              -- WardNumber (FK)
    'N002',             -- StaffNumber (FK)
    '2015-10-06',       -- DateWaitlisted
    '2015-10-07',       -- DatePlaced
    6,                  -- ExpectedStayDays
    '2015-10-13',       -- DateExpectedLeave
    NULL                -- DateActualDeparture (still admitted)
);

GO

-- STEP 1E: Insert MEDICATION record for the new patient
INSERT INTO MEDICATION VALUES 
(
    'A011',             -- AdminID
    'P1009',            -- PatientNumber (FK)
    'D002',             -- DrugNumber (FK) - Advil
    '10mg/ml',          -- DosagePerAdmin
    'Oral',             -- MethodOfAdmin
    '2015-10-07',       -- DateOfAdmin
    '09:00:00'          -- TimeOfAdmin
);

GO

-- VERIFY: Confirm new patient was inserted across all tables
PRINT '========================================';
PRINT 'TASK 1 VERIFICATION: New Patient Inserted';
PRINT '========================================';

SELECT 'PATIENT'     AS TableName, PatientNumber, FirstName, LastName 
FROM PATIENT WHERE PatientNumber = 'P1009';

SELECT 'APPOINTMENT' AS TableName, AppointmentNumber, AppointmentDate, PatientNumber 
FROM APPOINTMENT WHERE PatientNumber = 'P1009';

SELECT 'INPATIENT'   AS TableName, InpatientID, BedNumber, WardNumber, DateWaitlisted 
FROM INPATIENT WHERE PatientNumber = 'P1009';

SELECT 'MEDICATION'  AS TableName, AdminID, DrugNumber, MethodOfAdmin, DateOfAdmin 
FROM MEDICATION WHERE PatientNumber = 'P1009';

GO

-- TASK 2: UPDATE - Change the new patient's BED assignment

PRINT '========================================';
PRINT 'TASK 2: UPDATE Bed Assignment';
PRINT '========================================';

-- Show BEFORE the update
PRINT '--- BEFORE UPDATE ---';
SELECT InpatientID, PatientNumber, BedNumber, WardNumber 
FROM INPATIENT 
WHERE PatientNumber = 'P1009';

-- Perform the UPDATE
UPDATE INPATIENT
SET    BedNumber  = 'B07',
       WardNumber = 'W03'
WHERE  PatientNumber = 'P1009'
AND    InpatientID   = 'IP007';

-- Show AFTER the update
PRINT '--- AFTER UPDATE ---';
SELECT InpatientID, PatientNumber, BedNumber, WardNumber 
FROM INPATIENT 
WHERE PatientNumber = 'P1009';

GO

-- TASK 3: CREATE TRIGGER

-- Drop trigger if it already exists
IF OBJECT_ID('trg_PreventDuplicateBedAssignment', 'TR') IS NOT NULL
    DROP TRIGGER trg_PreventDuplicateBedAssignment;

GO

CREATE TRIGGER trg_PreventDuplicateBedAssignment
ON INPATIENT
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM   INPATIENT i
        JOIN   inserted  ins ON i.BedNumber = ins.BedNumber
        WHERE  i.DatePlaced           IS NOT NULL
        AND    i.DateActualDeparture  IS NULL
    )
    BEGIN
        RAISERROR(
            'ERROR: Bed assignment failed. This bed is already occupied by an active patient. Please choose a different bed.',
            16, -- Severity
            1   -- State
        );
        RETURN; -- Stop execution, do not insert
    END
    ELSE
    BEGIN
        -- Bed is available, allow the insert to proceed
        INSERT INTO INPATIENT (
            InpatientID,
            PatientNumber,
            BedNumber,
            WardNumber,
            StaffNumber,
            DateWaitlisted,
            DatePlaced,
            ExpectedStayDays,
            DateExpectedLeave,
            DateActualDeparture
        )
        SELECT 
            InpatientID,
            PatientNumber,
            BedNumber,
            WardNumber,
            StaffNumber,
            DateWaitlisted,
            DatePlaced,
            ExpectedStayDays,
            DateExpectedLeave,
            DateActualDeparture
        FROM inserted;

        PRINT 'SUCCESS: Bed assigned successfully.';
    END
END;

GO

-- TASK 4: PROVE THE TRIGGER WORKS

PRINT '========================================';
PRINT 'TASK 4: TRIGGER DEMONSTRATION';
PRINT '========================================';

PRINT '--- BEFORE: Current occupant of Bed B07 ---';

SELECT 
    i.InpatientID,
    i.BedNumber,
    i.PatientNumber,
    p.FirstName,
    p.LastName,
    i.DatePlaced,
    i.DateActualDeparture,
    CASE 
        WHEN i.DatePlaced IS NOT NULL 
         AND i.DateActualDeparture IS NULL 
        THEN 'OCCUPIED' 
        ELSE 'AVAILABLE' 
    END AS BedStatus
FROM   INPATIENT i
JOIN   PATIENT   p ON i.PatientNumber = p.PatientNumber
WHERE  i.BedNumber = 'B07';

GO

PRINT '--- TRIGGER TEST: Attempting to assign Bed B07 to a new patient ---';
PRINT '--- This should FAIL and show the error message ---';

INSERT INTO PATIENT VALUES 
(
    'P9999',
    'Test',
    'Patient',
    'M',
    '1950-01-01',
    'Single',
    '1 Test Street, Cincinnati OH 45201',
    '513-555-9999',
    'BlueCross',
    'BC999999',
    '2015-10-08',
    'PCP001'
);

GO

INSERT INTO INPATIENT VALUES 
(
    'IP999',            -- InpatientID
    'P9999',            -- PatientNumber
    'B07',              -- BedNumber: occupied, trigger should block this
    'W03',              -- WardNumber
    'N005',             -- StaffNumber
    '2015-10-08',       -- DateWaitlisted
    '2015-10-08',       -- DatePlaced
    3,                  -- ExpectedStayDays
    '2015-10-11',       -- DateExpectedLeave
    NULL                -- DateActualDeparture
);

GO

PRINT '--- AFTER: Confirming Bed B07 still belongs to original patient ---';

SELECT 
    i.InpatientID,
    i.BedNumber,
    i.PatientNumber,
    p.FirstName,
    p.LastName,
    i.DatePlaced,
    i.DateActualDeparture,
    CASE 
        WHEN i.DatePlaced IS NOT NULL 
         AND i.DateActualDeparture IS NULL 
        THEN 'OCCUPIED' 
        ELSE 'AVAILABLE' 
    END AS BedStatus
FROM   INPATIENT i
JOIN   PATIENT   p ON i.PatientNumber = p.PatientNumber
WHERE  i.BedNumber = 'B07';

GO

PRINT '--- Checking if P9999 made it into INPATIENT (should be 0 rows) ---';

SELECT COUNT(*) AS ShouldBeZero 
FROM INPATIENT 
WHERE PatientNumber = 'P9999';

GO

PRINT '--- BONUS: Assigning P9999 to available Bed B05 (should SUCCEED) ---';

INSERT INTO INPATIENT VALUES 
(
    'IP999',            -- InpatientID
    'P9999',            -- PatientNumber
    'B05',              -- BedNumber: available, trigger should allow this
    'W02',              -- WardNumber
    'N003',             -- StaffNumber
    '2015-10-08',       -- DateWaitlisted
    '2015-10-08',       -- DatePlaced
    3,                  -- ExpectedStayDays
    '2015-10-11',       -- DateExpectedLeave
    NULL                -- DateActualDeparture
);

GO

PRINT '--- FINAL: P9999 successfully assigned to available Bed B05 ---';

SELECT 
    i.InpatientID,
    i.BedNumber,
    i.PatientNumber,
    p.FirstName,
    p.LastName,
    CASE 
        WHEN i.DatePlaced IS NOT NULL 
         AND i.DateActualDeparture IS NULL 
        THEN 'OCCUPIED' 
        ELSE 'AVAILABLE' 
    END AS BedStatus
FROM   INPATIENT i
JOIN   PATIENT   p ON i.PatientNumber = p.PatientNumber
WHERE  i.PatientNumber = 'P9999';

GO

