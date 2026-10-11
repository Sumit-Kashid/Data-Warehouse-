-- KO_MED Hospital database: schema and seed data
-- Author: Sumit Kashid
-- Drops and recreates all 9 tables in 3NF, then loads sample data.

USE KO_MED_Hospital;
GO

-- SECTION 1: DROP TABLES

IF OBJECT_ID('MEDICATION', 'U') IS NOT NULL DROP TABLE MEDICATION;
IF OBJECT_ID('INPATIENT',  'U') IS NOT NULL DROP TABLE INPATIENT;
IF OBJECT_ID('APPOINTMENT','U') IS NOT NULL DROP TABLE APPOINTMENT;
IF OBJECT_ID('BED',        'U') IS NOT NULL DROP TABLE BED;
IF OBJECT_ID('PATIENT',    'U') IS NOT NULL DROP TABLE PATIENT;
IF OBJECT_ID('NURSE',      'U') IS NOT NULL DROP TABLE NURSE;
IF OBJECT_ID('DRUG',       'U') IS NOT NULL DROP TABLE DRUG;
IF OBJECT_ID('WARD',       'U') IS NOT NULL DROP TABLE WARD;
IF OBJECT_ID('PCP',        'U') IS NOT NULL DROP TABLE PCP;

GO

-- SECTION 2: CREATE TABLES
-- Create in correct order (parent tables first, then children)
-- TABLE 1: WARD
CREATE TABLE WARD (
    WardNumber          VARCHAR(10)     NOT NULL,
    WardName            VARCHAR(50)     NOT NULL,
    Location            VARCHAR(50)     NOT NULL,
    NumberOfBeds        INT             NOT NULL,
    TelephoneExtension  CHAR(5)         NOT NULL,
    CONSTRAINT PK_WARD PRIMARY KEY (WardNumber)
);

GO

-- TABLE 2: PCP (Primary Care Physician)

CREATE TABLE PCP (
    PracticeNumber      VARCHAR(10)     NOT NULL,
    PCPName             VARCHAR(100)    NOT NULL,
    Address             VARCHAR(200)    NOT NULL,
    Telephone           VARCHAR(15)     NOT NULL,
    CONSTRAINT PK_PCP PRIMARY KEY (PracticeNumber)
);

GO

-- TABLE 3: NURSE

CREATE TABLE NURSE (
    StaffNumber         VARCHAR(10)     NOT NULL,
    FirstName           VARCHAR(50)     NOT NULL,
    LastName            VARCHAR(50)     NOT NULL,
    Gender              CHAR(1)         NOT NULL,
    DateOfBirth         DATE            NOT NULL,
    Address             VARCHAR(200)    NOT NULL,
    Telephone           VARCHAR(15)     NOT NULL,
    CurrentTitle        VARCHAR(50)     NOT NULL,
    CurrentSalary       DECIMAL(10,2)   NOT NULL,
    Shift               CHAR(1)         NOT NULL,
    WardNumber          VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_NURSE     PRIMARY KEY (StaffNumber),
    CONSTRAINT FK_NURSE_WARD FOREIGN KEY (WardNumber) REFERENCES WARD(WardNumber),
    CONSTRAINT CK_NURSE_GENDER  CHECK (Gender IN ('M','F')),
    CONSTRAINT CK_NURSE_SHIFT   CHECK (Shift  IN ('A','B','C'))
);

GO

-- TABLE 4: BED

CREATE TABLE BED (
    BedNumber           VARCHAR(10)     NOT NULL,
    WardNumber          VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_BED       PRIMARY KEY (BedNumber),
    CONSTRAINT FK_BED_WARD  FOREIGN KEY (WardNumber) REFERENCES WARD(WardNumber)
);

GO

-- TABLE 5: PATIENT

CREATE TABLE PATIENT (
    PatientNumber       VARCHAR(10)     NOT NULL,
    FirstName           VARCHAR(50)     NOT NULL,
    LastName            VARCHAR(50)     NOT NULL,
    Gender              CHAR(1)         NOT NULL,
    DateOfBirth         DATE            NOT NULL,
    MaritalStatus       VARCHAR(10)     NOT NULL,
    Address             VARCHAR(200)    NOT NULL,
    Telephone           VARCHAR(15)     NOT NULL,
    InsuranceProvider   VARCHAR(100)    NOT NULL,
    InsuranceNumber     VARCHAR(20)     NOT NULL,
    DateRegistered      DATE            NOT NULL,
    PracticeNumber      VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_PATIENT       PRIMARY KEY (PatientNumber),
    CONSTRAINT FK_PATIENT_PCP   FOREIGN KEY (PracticeNumber) REFERENCES PCP(PracticeNumber),
    CONSTRAINT CK_PATIENT_GENDER        CHECK (Gender        IN ('M','F')),
    CONSTRAINT CK_PATIENT_MARITAL       CHECK (MaritalStatus IN ('Married','Single'))
);

GO

-- TABLE 6: APPOINTMENT

CREATE TABLE APPOINTMENT (
    AppointmentNumber       VARCHAR(10)     NOT NULL,
    AppointmentDate         DATE            NOT NULL,
    AppointmentTime         TIME            NOT NULL,
    ExaminationRoomNumber   VARCHAR(10)     NOT NULL,
    PatientNumber           VARCHAR(10)     NOT NULL,
    StaffNumber             VARCHAR(10)     NOT NULL,
    CONSTRAINT PK_APPOINTMENT           PRIMARY KEY (AppointmentNumber),
    CONSTRAINT FK_APPT_PATIENT          FOREIGN KEY (PatientNumber) REFERENCES PATIENT(PatientNumber),
    CONSTRAINT FK_APPT_NURSE            FOREIGN KEY (StaffNumber)   REFERENCES NURSE(StaffNumber)
);

GO

-- TABLE 7: DRUG

CREATE TABLE DRUG (
    DrugNumber          VARCHAR(10)     NOT NULL,
    DrugName            VARCHAR(100)    NOT NULL,
    Description         VARCHAR(200)    NOT NULL,
    CONSTRAINT PK_DRUG PRIMARY KEY (DrugNumber)
);

GO

-- TABLE 8: INPATIENT

CREATE TABLE INPATIENT (
    InpatientID             VARCHAR(10)     NOT NULL,
    PatientNumber           VARCHAR(10)     NOT NULL,
    BedNumber               VARCHAR(10)     NOT NULL,
    WardNumber              VARCHAR(10)     NOT NULL,
    StaffNumber             VARCHAR(10)     NOT NULL,
    DateWaitlisted          DATE            NOT NULL,
    DatePlaced              DATE                NULL,
    ExpectedStayDays        INT                 NULL,
    DateExpectedLeave       DATE                NULL,
    DateActualDeparture     DATE                NULL,
    CONSTRAINT PK_INPATIENT         PRIMARY KEY (InpatientID),
    CONSTRAINT FK_INPAT_PATIENT     FOREIGN KEY (PatientNumber) REFERENCES PATIENT(PatientNumber),
    CONSTRAINT FK_INPAT_BED         FOREIGN KEY (BedNumber)     REFERENCES BED(BedNumber),
    CONSTRAINT FK_INPAT_WARD        FOREIGN KEY (WardNumber)    REFERENCES WARD(WardNumber),
    CONSTRAINT FK_INPAT_NURSE       FOREIGN KEY (StaffNumber)   REFERENCES NURSE(StaffNumber)
);

GO

-- TABLE 9: MEDICATION

CREATE TABLE MEDICATION (
    AdminID             VARCHAR(10)     NOT NULL,
    PatientNumber       VARCHAR(10)     NOT NULL,
    DrugNumber          VARCHAR(10)     NOT NULL,
    DosagePerAdmin      VARCHAR(20)     NOT NULL,
    MethodOfAdmin       VARCHAR(10)     NOT NULL,
    DateOfAdmin         DATE            NOT NULL,
    TimeOfAdmin         TIME            NOT NULL,
    CONSTRAINT PK_MEDICATION        PRIMARY KEY (AdminID),
    CONSTRAINT FK_MED_PATIENT       FOREIGN KEY (PatientNumber) REFERENCES PATIENT(PatientNumber),
    CONSTRAINT FK_MED_DRUG          FOREIGN KEY (DrugNumber)    REFERENCES DRUG(DrugNumber),
    CONSTRAINT CK_MED_METHOD        CHECK (MethodOfAdmin IN ('Oral','IV'))
);

GO

-- SECTION 3: INSERT DATA

-- INSERT: WARD (5 wards)

INSERT INTO WARD VALUES ('W01', 'Orthopedic',   'Building C', 20, '12301');
INSERT INTO WARD VALUES ('W02', 'Cardiology',   'Building A', 15, '12302');
INSERT INTO WARD VALUES ('W03', 'Neurology',    'Building B', 18, '12303');
INSERT INTO WARD VALUES ('W04', 'Geriatrics',   'Building D', 25, '12304');
INSERT INTO WARD VALUES ('W05', 'Pulmonology',  'Building E', 12, '12305');

GO

-- INSERT: PCP (5 primary care physicians)

INSERT INTO PCP VALUES ('PCP001', 'Dr. Robert Smith',   '456 Oak Avenue, Cincinnati OH 45201',      '513-555-1001');
INSERT INTO PCP VALUES ('PCP002', 'Dr. Linda Jones',    '789 Pine Road, Cincinnati OH 45202',       '513-555-1002');
INSERT INTO PCP VALUES ('PCP003', 'Dr. James Williams', '321 Maple Street, Cincinnati OH 45203',    '513-555-1003');
INSERT INTO PCP VALUES ('PCP004', 'Dr. Patricia Brown', '654 Elm Boulevard, Cincinnati OH 45204',   '513-555-1004');
INSERT INTO PCP VALUES ('PCP005', 'Dr. Michael Davis',  '987 Cedar Lane, Cincinnati OH 45205',      '513-555-1005');

GO

-- INSERT: NURSE (10 nurses across all shifts and wards)

INSERT INTO NURSE VALUES ('N001', 'Jennifer', 'Adams',   'F', '1985-03-15', '100 Birch St, Cincinnati OH 45201', '513-555-2001', 'RN',       '58000.00', 'A', 'W01');
INSERT INTO NURSE VALUES ('N002', 'Michael',  'Baker',   'M', '1978-07-22', '200 Cedar St, Cincinnati OH 45202', '513-555-2002', 'RN',       '60000.00', 'A', 'W01');
INSERT INTO NURSE VALUES ('N003', 'Susan',    'Clark',   'F', '1990-11-08', '300 Daisy St, Cincinnati OH 45203', '513-555-2003', 'Charge RN','65000.00', 'B', 'W02');
INSERT INTO NURSE VALUES ('N004', 'David',    'Evans',   'M', '1982-05-30', '400 Elm St, Cincinnati OH 45204',   '513-555-2004', 'RN',       '57000.00', 'B', 'W02');
INSERT INTO NURSE VALUES ('N005', 'Karen',    'Foster',  'F', '1975-09-14', '500 Fern St, Cincinnati OH 45205',  '513-555-2005', 'Charge RN','67000.00', 'A', 'W03');
INSERT INTO NURSE VALUES ('N006', 'Thomas',   'Green',   'M', '1988-01-25', '600 Grove St, Cincinnati OH 45201', '513-555-2006', 'RN',       '56000.00', 'C', 'W03');
INSERT INTO NURSE VALUES ('N007', 'Patricia', 'Harris',  'F', '1983-06-17', '700 Hill St, Cincinnati OH 45202',  '513-555-2007', 'RN',       '59000.00', 'B', 'W04');
INSERT INTO NURSE VALUES ('N008', 'James',    'Irving',  'M', '1991-12-03', '800 Ivy St, Cincinnati OH 45203',   '513-555-2008', 'RN',       '55000.00', 'C', 'W04');
INSERT INTO NURSE VALUES ('N009', 'Linda',    'Johnson', 'F', '1980-04-19', '900 Jade St, Cincinnati OH 45204',  '513-555-2009', 'Charge RN','66000.00', 'A', 'W05');
INSERT INTO NURSE VALUES ('N010', 'Charles',  'King',    'M', '1977-08-11', '101 Kale St, Cincinnati OH 45205',  '513-555-2010', 'RN',       '57500.00', 'C', 'W05');

GO

-- INSERT: BED (10 beds across wards)

INSERT INTO BED VALUES ('B01', 'W01');
INSERT INTO BED VALUES ('B02', 'W01');
INSERT INTO BED VALUES ('B03', 'W01');
INSERT INTO BED VALUES ('B04', 'W02');
INSERT INTO BED VALUES ('B05', 'W02');
INSERT INTO BED VALUES ('B06', 'W03');
INSERT INTO BED VALUES ('B07', 'W03');
INSERT INTO BED VALUES ('B08', 'W04');
INSERT INTO BED VALUES ('B09', 'W04');
INSERT INTO BED VALUES ('B10', 'W05');

GO

-- INSERT: PATIENT (8 patients, all aged 60+)

INSERT INTO PATIENT VALUES ('P1001', 'George',   'Anderson', 'M', '1948-02-14', 'Married', '11 Sunset Blvd, Cincinnati OH 45201',  '513-555-3001', 'BlueCross',  'BC100123', '2015-09-25', 'PCP001');
INSERT INTO PATIENT VALUES ('P1002', 'Margaret', 'Bennett',  'F', '1952-06-30', 'Single',  '22 Sunrise Ave, Cincinnati OH 45202',  '513-555-3002', 'Aetna',      'AE200234', '2015-09-26', 'PCP001');
INSERT INTO PATIENT VALUES ('P1003', 'Harold',   'Carter',   'M', '1944-11-05', 'Married', '33 Moonlight Dr, Cincinnati OH 45203', '513-555-3003', 'UnitedHealth','UH300345','2015-09-27', 'PCP002');
INSERT INTO PATIENT VALUES ('P1004', 'Dorothy',  'Dixon',    'F', '1950-03-22', 'Single',  '44 Starlight Ln, Cincinnati OH 45204', '513-555-3004', 'Humana',     'HU400456', '2015-09-28', 'PCP002');
INSERT INTO PATIENT VALUES ('P1005', 'Walter',   'Edwards',  'M', '1955-07-18', 'Married', '55 Rainbow Rd, Cincinnati OH 45205',   '513-555-3005', 'BlueCross',  'BC500567', '2015-09-29', 'PCP003');
INSERT INTO PATIENT VALUES ('P1006', 'Helen',    'Fisher',   'F', '1947-09-09', 'Married', '66 Valley View, Cincinnati OH 45201',  '513-555-3006', 'Aetna',      'AE600678', '2015-09-30', 'PCP003');
INSERT INTO PATIENT VALUES ('P1007', 'Frank',    'Gibson',   'M', '1953-12-01', 'Single',  '77 River Bend, Cincinnati OH 45202',   '513-555-3007', 'Cigna',      'CI700789', '2015-10-01', 'PCP004');
INSERT INTO PATIENT VALUES ('P1008', 'Ruth',     'Hamilton', 'F', '1949-04-27', 'Married', '88 Lake Shore, Cincinnati OH 45203',   '513-555-3008', 'UnitedHealth','UH800890','2015-10-02', 'PCP005');

GO

-- INSERT: APPOINTMENT (8 appointments)

INSERT INTO APPOINTMENT VALUES ('APT001', '2015-09-26', '09:00:00', 'Room 1', 'P1001', 'N001');
INSERT INTO APPOINTMENT VALUES ('APT002', '2015-09-27', '10:30:00', 'Room 2', 'P1002', 'N001');
INSERT INTO APPOINTMENT VALUES ('APT003', '2015-09-28', '11:00:00', 'Room 3', 'P1003', 'N003');
INSERT INTO APPOINTMENT VALUES ('APT004', '2015-09-29', '14:00:00', 'Room 1', 'P1004', 'N003');
INSERT INTO APPOINTMENT VALUES ('APT005', '2015-09-30', '09:30:00', 'Room 4', 'P1005', 'N005');
INSERT INTO APPOINTMENT VALUES ('APT006', '2015-10-01', '13:00:00', 'Room 2', 'P1006', 'N005');
INSERT INTO APPOINTMENT VALUES ('APT007', '2015-10-02', '10:00:00', 'Room 3', 'P1007', 'N007');
INSERT INTO APPOINTMENT VALUES ('APT008', '2015-10-03', '11:30:00', 'Room 5', 'P1008', 'N009');

GO
-- INSERT: DRUG (5 drugs)
INSERT INTO DRUG VALUES ('D001', 'Penicillin',   'Antibiotic used to treat bacterial infections');
INSERT INTO DRUG VALUES ('D002', 'Advil',        'NSAID pain reliever and anti-inflammatory');
INSERT INTO DRUG VALUES ('D003', 'Lisinopril',   'ACE inhibitor used to treat high blood pressure');
INSERT INTO DRUG VALUES ('D004', 'Metformin',    'Oral diabetes medicine to control blood sugar');
INSERT INTO DRUG VALUES ('D005', 'Atorvastatin', 'Statin used to lower cholesterol levels');

GO

-- INSERT: INPATIENT (6 inpatients placed in wards)

INSERT INTO INPATIENT VALUES ('IP001', 'P1001', 'B01', 'W01', 'N001', '2015-09-26', '2015-09-30', 5,  '2015-10-05', '2015-10-07');
INSERT INTO INPATIENT VALUES ('IP002', 'P1002', 'B02', 'W01', 'N001', '2015-09-27', '2015-10-01', 7,  '2015-10-08', NULL);
INSERT INTO INPATIENT VALUES ('IP003', 'P1003', 'B04', 'W02', 'N003', '2015-09-28', '2015-10-02', 10, '2015-10-12', '2015-10-11');
INSERT INTO INPATIENT VALUES ('IP004', 'P1004', 'B06', 'W03', 'N005', '2015-09-29', '2015-10-03', 6,  '2015-10-09', NULL);
INSERT INTO INPATIENT VALUES ('IP005', 'P1005', 'B08', 'W04', 'N007', '2015-09-30', '2015-10-04', 8,  '2015-10-12', '2015-10-13');
INSERT INTO INPATIENT VALUES ('IP006', 'P1006', 'B10', 'W05', 'N009', '2015-10-01', NULL,         NULL, NULL,        NULL);

GO

-- INSERT: MEDICATION (10 medication records)

INSERT INTO MEDICATION VALUES ('A001', 'P1001', 'D001', '1mg/ml',  'IV',   '2015-10-01', '08:45:00');
INSERT INTO MEDICATION VALUES ('A002', 'P1001', 'D002', '15mg/ml', 'Oral', '2015-10-02', '17:26:00');
INSERT INTO MEDICATION VALUES ('A003', 'P1002', 'D003', '10mg',    'Oral', '2015-10-02', '09:00:00');
INSERT INTO MEDICATION VALUES ('A004', 'P1002', 'D005', '20mg',    'Oral', '2015-10-02', '20:00:00');
INSERT INTO MEDICATION VALUES ('A005', 'P1003', 'D001', '2mg/ml',  'IV',   '2015-10-03', '10:15:00');
INSERT INTO MEDICATION VALUES ('A006', 'P1003', 'D004', '500mg',   'Oral', '2015-10-03', '13:30:00');
INSERT INTO MEDICATION VALUES ('A007', 'P1004', 'D002', '10mg/ml', 'Oral', '2015-10-04', '08:00:00');
INSERT INTO MEDICATION VALUES ('A008', 'P1005', 'D003', '5mg',     'Oral', '2015-10-05', '09:30:00');
INSERT INTO MEDICATION VALUES ('A009', 'P1005', 'D005', '40mg',    'Oral', '2015-10-05', '20:30:00');
INSERT INTO MEDICATION VALUES ('A010', 'P1006', 'D004', '850mg',   'Oral', '2015-10-06', '12:00:00');

GO

-- SECTION 4: VERIFY ROW COUNTS

SELECT 'WARD'        AS TableName, COUNT(*) AS RecordCount FROM WARD        UNION ALL
SELECT 'PCP'         AS TableName, COUNT(*) AS RecordCount FROM PCP         UNION ALL
SELECT 'NURSE'       AS TableName, COUNT(*) AS RecordCount FROM NURSE       UNION ALL
SELECT 'BED'         AS TableName, COUNT(*) AS RecordCount FROM BED         UNION ALL
SELECT 'PATIENT'     AS TableName, COUNT(*) AS RecordCount FROM PATIENT     UNION ALL
SELECT 'APPOINTMENT' AS TableName, COUNT(*) AS RecordCount FROM APPOINTMENT UNION ALL
SELECT 'DRUG'        AS TableName, COUNT(*) AS RecordCount FROM DRUG        UNION ALL
SELECT 'INPATIENT'   AS TableName, COUNT(*) AS RecordCount FROM INPATIENT   UNION ALL
SELECT 'MEDICATION'  AS TableName, COUNT(*) AS RecordCount FROM MEDICATION;

GO