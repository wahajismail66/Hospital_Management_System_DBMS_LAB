-- =====================================================
-- Hospital Management System – Corrected Database
-- With simplified audit triggers (no XML PATH)
-- =====================================================

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'Hospital_Final_Project')
BEGIN
    ALTER DATABASE Hospital_Final_Project SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Hospital_Final_Project;
END
GO

CREATE DATABASE Hospital_Final_Project;
GO

USE Hospital_Final_Project;
GO

-- ========== CORE TABLES (as before) ==========
CREATE TABLE Specializations (
    SpecializationID INT PRIMARY KEY IDENTITY(1,1),
    SpecializationName NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    SpecializationID INT FOREIGN KEY REFERENCES Specializations(SpecializationID),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    ConsultationFee DECIMAL(10,2) DEFAULT 0,
    Qualification NVARCHAR(200)
);

CREATE TABLE DoctorAvailability (
    AvailabilityID INT PRIMARY KEY IDENTITY(1,1),
    DoctorID INT FOREIGN KEY REFERENCES Doctors(DoctorID),
    DayOfWeek INT NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    SlotDuration INT DEFAULT 30
);

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE,
    Gender NVARCHAR(10),
    Phone NVARCHAR(20) NOT NULL,
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    BloodGroup NVARCHAR(5),
    RegistrationDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Nurses (
    NurseID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    AssignedDoctorID INT FOREIGN KEY REFERENCES Doctors(DoctorID) NULL,
    HireDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID),
    DoctorID INT FOREIGN KEY REFERENCES Doctors(DoctorID),
    NurseID INT FOREIGN KEY REFERENCES Nurses(NurseID) NULL,
    AppointmentDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Scheduled',
    Symptoms NVARCHAR(500),
    CreatedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT FOREIGN KEY REFERENCES Appointments(AppointmentID),
    Diagnosis NVARCHAR(500),
    Medicines NVARCHAR(MAX),
    Advice NVARCHAR(MAX),
    FollowUpDate DATE,
    PrescribedDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Bills (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT FOREIGN KEY REFERENCES Appointments(AppointmentID),
    ConsultationFee DECIMAL(10,2) NOT NULL,
    AdditionalCharges DECIMAL(10,2) DEFAULT 0,
    TotalAmount DECIMAL(10,2),
    PaidAmount DECIMAL(10,2) DEFAULT 0,
    PaymentStatus NVARCHAR(20) DEFAULT 'Unpaid',
    PaymentDate DATETIME NULL
);

-- ========== LOGIN TABLES ==========
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    RoleID INT FOREIGN KEY REFERENCES Roles(RoleID),
    RelatedID INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- ========== ADVANCED MODULES ==========
CREATE TABLE Wards (
    WardID INT PRIMARY KEY IDENTITY(1,1),
    WardName NVARCHAR(50) NOT NULL,
    WardType NVARCHAR(50)
);

CREATE TABLE Beds (
    BedID INT PRIMARY KEY IDENTITY(1,1),
    WardID INT FOREIGN KEY REFERENCES Wards(WardID),
    BedNumber NVARCHAR(10) NOT NULL,
    IsOccupied BIT DEFAULT 0
);

CREATE TABLE Admissions (
    AdmissionID INT PRIMARY KEY IDENTITY(1,1),
    PatientID INT FOREIGN KEY REFERENCES Patients(PatientID),
    BedID INT FOREIGN KEY REFERENCES Beds(BedID),
    AdmitDate DATETIME DEFAULT GETDATE(),
    DischargeDate DATETIME NULL,
    Diagnosis NVARCHAR(500)
);

CREATE TABLE TestCategories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE LabTests (
    TestID INT PRIMARY KEY IDENTITY(1,1),
    TestName NVARCHAR(100) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES TestCategories(CategoryID),
    Price DECIMAL(10,2),
    NormalRange NVARCHAR(100)
);

CREATE TABLE LabOrders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    AppointmentID INT FOREIGN KEY REFERENCES Appointments(AppointmentID),
    TestID INT FOREIGN KEY REFERENCES LabTests(TestID),
    OrderedDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Pending',
    ResultValue NVARCHAR(500),
    IsNormal BIT,
    ResultDate DATETIME NULL
);

CREATE TABLE Medicines (
    MedicineID INT PRIMARY KEY IDENTITY(1,1),
    MedicineName NVARCHAR(100) NOT NULL,
    StockQuantity INT DEFAULT 0,
    Price DECIMAL(10,2),
    ReorderLevel INT DEFAULT 10
);

CREATE TABLE PrescriptionItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    PrescriptionID INT FOREIGN KEY REFERENCES Prescriptions(PrescriptionID),
    MedicineID INT FOREIGN KEY REFERENCES Medicines(MedicineID),
    Dosage NVARCHAR(100),
    DurationDays INT,
    Quantity INT
);

-- ========== AUDIT LOG TABLE ==========
CREATE TABLE AuditLog (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    Timestamp DATETIME DEFAULT GETDATE(),
    Username NVARCHAR(50),
    Action NVARCHAR(20),
    TableName NVARCHAR(50),
    RecordID INT
);

CREATE TABLE EmailLog (
    EmailLogID INT PRIMARY KEY IDENTITY(1,1),
    RecipientEmail NVARCHAR(100),
    Subject NVARCHAR(255),
    SentDate DATETIME DEFAULT GETDATE(),
    Status NVARCHAR(20)
);

-- ========== SAMPLE DATA ==========
INSERT INTO Specializations (SpecializationName) VALUES 
('Cardiologist'), ('Dermatologist'), ('Neurologist'), ('Pediatrician'), ('Orthopedic'), ('General Physician');

INSERT INTO Doctors (FullName, SpecializationID, Phone, Email, ConsultationFee) VALUES
('Dr. John Smith', (SELECT SpecializationID FROM Specializations WHERE SpecializationName='General Physician'), '1234567890', 'john.smith@hospital.com', 50),
('Dr. Sarah Chen', (SELECT SpecializationID FROM Specializations WHERE SpecializationName='Cardiologist'), '03111234567', 'sarah.chen@hospital.com', 80),
('Dr. Ali Raza', (SELECT SpecializationID FROM Specializations WHERE SpecializationName='Dermatologist'), '03119876543', 'ali.raza@hospital.com', 60);

INSERT INTO DoctorAvailability (DoctorID, DayOfWeek, StartTime, EndTime, SlotDuration) VALUES
(1,0,'09:00','17:00',30),(1,1,'09:00','17:00',30),(1,2,'09:00','17:00',30),(1,3,'09:00','17:00',30),(1,4,'09:00','17:00',30),
(2,0,'08:00','16:00',30),(2,1,'08:00','16:00',30),(2,2,'08:00','16:00',30),(2,3,'08:00','16:00',30),(2,4,'09:00','13:00',30),
(3,0,'10:00','18:00',30),(3,2,'10:00','18:00',30),(3,4,'10:00','18:00',30);

INSERT INTO Patients (FullName, DateOfBirth, Gender, Phone, Email, BloodGroup) VALUES
('John Doe', '1985-06-15', 'Male', '03001234567', 'john.doe@example.com', 'O+'),
('Jane Smith', '1990-09-22', 'Female', '03009876543', 'jane.smith@example.com', 'A+'),
('Robert Khan', '1978-03-10', 'Male', '03005551234', 'robert.khan@example.com', 'B+');

INSERT INTO Nurses (FullName, Phone, Email, AssignedDoctorID) VALUES
('Nurse Emma', '03211234567', 'emma@hospital.com', 1),
('Nurse Lisa', '03219876543', 'lisa@hospital.com', 2),
('Nurse Samina', '03215551234', 'samina@hospital.com', 3);

INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, StartTime, EndTime, Status, Symptoms) VALUES
(1, 1, DATEADD(day, -5, GETDATE()), '09:00', '09:30', 'Completed', 'Cough and fever'),
(2, 2, DATEADD(day, -3, GETDATE()), '10:30', '11:00', 'Completed', 'Chest pain'),
(1, 1, DATEADD(day, 2, GETDATE()), '11:00', '11:30', 'Scheduled', 'Follow-up');

INSERT INTO Prescriptions (AppointmentID, Diagnosis, Medicines, Advice) VALUES
(1, 'Acute bronchitis', 'Amoxicillin 500mg – twice daily', 'Rest and fluids');

INSERT INTO Bills (AppointmentID, ConsultationFee, TotalAmount, PaidAmount, PaymentStatus) VALUES
(1, 50, 50, 50, 'Paid');

INSERT INTO Roles (RoleName) VALUES ('Admin'), ('Doctor'), ('Receptionist'), ('Patient');

INSERT INTO Users (Username, PasswordHash, RoleID, RelatedID) VALUES
('admin', 'admin123', (SELECT RoleID FROM Roles WHERE RoleName='Admin'), NULL),
('dr.smith', 'dr.smith', (SELECT RoleID FROM Roles WHERE RoleName='Doctor'), 1),
('reception', 'reception', (SELECT RoleID FROM Roles WHERE RoleName='Receptionist'), NULL),
('john.doe', 'john.doe', (SELECT RoleID FROM Roles WHERE RoleName='Patient'), 1);

INSERT INTO Wards (WardName, WardType) VALUES ('ICU', 'Intensive Care'), ('General Ward', 'General');
INSERT INTO Beds (WardID, BedNumber, IsOccupied) VALUES (1,'ICU-01',0),(1,'ICU-02',0),(2,'G-01',0),(2,'G-02',0);
INSERT INTO TestCategories (CategoryName) VALUES ('Blood'), ('Urine'), ('Radiology');
INSERT INTO LabTests (TestName, CategoryID, Price, NormalRange) VALUES
('Complete Blood Count',1,30,'4.5-11.0'),
('Blood Glucose',1,20,'70-100'),
('Chest X-Ray',3,50,'Normal');
INSERT INTO Medicines (MedicineName, StockQuantity, Price, ReorderLevel) VALUES
('Paracetamol',500,5,50),
('Amoxicillin',200,12,30),
('Lisinopril',150,25,20);

-- ========== SIMPLIFIED AUDIT TRIGGERS (each in its own batch) ==========
GO

CREATE TRIGGER trg_Patients_Audit ON Patients AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'UPDATE', 'Patients', (SELECT TOP 1 PatientID FROM inserted));
    ELSE IF EXISTS (SELECT * FROM inserted)
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'INSERT', 'Patients', (SELECT TOP 1 PatientID FROM inserted));
    ELSE
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'DELETE', 'Patients', (SELECT TOP 1 PatientID FROM deleted));
END;
GO

CREATE TRIGGER trg_Doctors_Audit ON Doctors AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'UPDATE', 'Doctors', (SELECT TOP 1 DoctorID FROM inserted));
    ELSE IF EXISTS (SELECT * FROM inserted)
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'INSERT', 'Doctors', (SELECT TOP 1 DoctorID FROM inserted));
    ELSE
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'DELETE', 'Doctors', (SELECT TOP 1 DoctorID FROM deleted));
END;
GO

CREATE TRIGGER trg_Appointments_Audit ON Appointments AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'UPDATE', 'Appointments', (SELECT TOP 1 AppointmentID FROM inserted));
    ELSE IF EXISTS (SELECT * FROM inserted)
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'INSERT', 'Appointments', (SELECT TOP 1 AppointmentID FROM inserted));
    ELSE
        INSERT INTO AuditLog (Username, Action, TableName, RecordID)
        VALUES (SYSTEM_USER, 'DELETE', 'Appointments', (SELECT TOP 1 AppointmentID FROM deleted));
END;
GO

PRINT 'Database created and audit triggers enabled.';