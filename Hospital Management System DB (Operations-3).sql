USE Hospital

--Q1
CREATE OR ALTER PROCEDURE GetAllPatients
AS
BEGIN
    SELECT * FROM Patients
END

--Q2
CREATE OR ALTER PROCEDURE GetAllConsultants
AS
BEGIN
    SELECT Id, [Name], Salary FROM Consultants
END

--Q3 
CREATE OR ALTER PROCEDURE GetPatientsWithWards
AS
BEGIN
    SELECT p.Id AS PatientId, p.[Name] AS PatientName, w.[Name] AS WardName
    FROM Patients p
    LEFT JOIN Wards w ON p.WardId = w.Id
END

--Q4
CREATE OR ALTER PROCEDURE GetPatientById
    @PatientId INT
AS
BEGIN
    SELECT * FROM Patients WHERE Id = @PatientId
END

--Q5
CREATE OR ALTER PROCEDURE GetConsultantsByMinSalary
    @MinSalary DECIMAL(18, 2)
AS
BEGIN
    SELECT * FROM Consultants WHERE Salary >= @MinSalary
END

--Q6 
CREATE OR ALTER PROCEDURE GetPatientsByWard_PR 
    @WardId INT
AS
BEGIN
    SELECT * FROM Patients WHERE WardId = @WardId
END

--Q7
CREATE OR ALTER PROCEDURE GetTotalPatientCount
    @TotalCount INT OUTPUT
AS
BEGIN
    SELECT @TotalCount = COUNT(Id) FROM Patients
END

--Q8
CREATE OR ALTER PROCEDURE GetAvgConsultantSalary
    @AvgSalary DECIMAL(18, 2) OUTPUT
AS
BEGIN
    SELECT @AvgSalary = AVG(Salary) FROM Consultants
END

--Q9
CREATE OR ALTER PROCEDURE GetPatientTotalMedicationQuantity
    @PatientId INT,
    @TotalQuantity INT OUTPUT
AS
BEGIN
    SELECT @TotalQuantity = COUNT(DrugCode) 
    FROM DrugAdministrations 
    WHERE PatientId = @PatientId
END

--Q10
CREATE OR ALTER PROCEDURE IncreaseSalary
    @Salary DECIMAL(18, 2) OUTPUT,
    @Percentage DECIMAL(5, 2)
AS
BEGIN
    SET @Salary = @Salary + (@Salary * (@Percentage / 100.0))
END

--Q11
CREATE OR ALTER PROCEDURE IncreaseMedicationQuantity
    @Quantity INT OUTPUT,
    @AddedQuantity INT
AS
BEGIN
    SET @Quantity = @Quantity + @AddedQuantity
END

--Q12
CREATE OR ALTER PROCEDURE ConvertMonthlyToAnnualSalary
    @Salary DECIMAL(18, 2) OUTPUT
AS
BEGIN
    SET @Salary = @Salary * 12
END

--Q13
CREATE OR ALTER PROCEDURE InsertPatientWithTryCatch
    @Name NVARCHAR(150),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    BEGIN TRY
        INSERT INTO Patients ([Name], DOB, WardId)
        VALUES (@Name, @DOB, @WardId)
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END

--Q14
CREATE OR ALTER PROCEDURE UpdateConsultantSalaryWithTryCatch
    @ConsultantId INT,
    @NewSalary DECIMAL(18, 2)
AS
BEGIN
    BEGIN TRY
        UPDATE Consultants
        SET Salary = @NewSalary
        WHERE Id = @ConsultantId
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END

--Q15
CREATE OR ALTER PROCEDURE DeletePatientWithTryCatch
    @PatientId INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM Patients WHERE Id = @PatientId;
    END TRY
    BEGIN CATCH
        SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END

--Q16
CREATE OR ALTER PROCEDURE AddPatient
    @Name NVARCHAR(150),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    INSERT INTO Patients ([Name], DOB, WardId)
    VALUES (@Name, @DOB, @WardId)
END

--Q17
CREATE OR ALTER PROCEDURE AddConsultant
    @Name NVARCHAR(150),
    @Salary DECIMAL(18, 2)
AS
BEGIN
    INSERT INTO Consultants ([Name], Salary)
    VALUES (@Name, @Salary)
END

--Q18
CREATE OR ALTER PROCEDURE AddMedicationAdministration
    @NurseId INT,
    @DrugCode INT,
    @PatientId INT,
    @Dosage NVARCHAR(50),
    @Date DATE,
    @Time TIME
AS
BEGIN
    INSERT INTO DrugAdministrations (NurseId, DrugCode, PatientId, Dosage, [DATE], [Time])
    VALUES (@NurseId, @DrugCode, @PatientId, @Dosage, @Date, @Time)
END

--Q19
CREATE OR ALTER PROCEDURE UpdatePatientInfo
    @PatientId INT,
    @Name NVARCHAR(150),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    UPDATE Patients
    SET [Name] = @Name, DOB = @DOB, WardId = @WardId
    WHERE Id = @PatientId
END

--Q20
CREATE OR ALTER PROCEDURE UpdateConsultantSalary
    @ConsultantId INT,
    @NewSalary DECIMAL(18, 2)
AS
BEGIN
    UPDATE Consultants
    SET Salary = @NewSalary
    WHERE Id = @ConsultantId
END

--Q21
CREATE OR ALTER PROCEDURE IncreaseNurseSalary
    @NurseNumber INT,
    @Percentage DECIMAL(5, 2)
AS
BEGIN
    UPDATE Nurses
    SET Salary = Salary + (Salary * (@Percentage / 100.0))
    WHERE Number = @NurseNumber
END

--Q22
CREATE OR ALTER PROCEDURE DeletePatient
    @PatientId INT
AS
BEGIN
    DELETE FROM Patients WHERE Id = @PatientId
END

--Q23
CREATE OR ALTER PROCEDURE DeleteConsultant
    @ConsultantId INT
AS
BEGIN
    DELETE FROM Consultants WHERE Id = @ConsultantId
END

--Q24
CREATE OR ALTER PROCEDURE DeleteMedicationAdministration
    @NurseId INT,
    @DrugCode INT,
    @PatientId INT,
    @Date DATE,
    @Time TIME
AS
BEGIN
    DELETE FROM DrugAdministrations
    WHERE NurseId = @NurseId 
      AND DrugCode = @DrugCode 
      AND PatientId = @PatientId
      AND [DATE] = @Date 
      AND [Time] = @Time
END

--Q25
CREATE TABLE StoredPatients (
    Id INT,
    [Name] NVARCHAR(150),
    DOB DATE,
    WardId INT
)
INSERT INTO StoredPatients
EXEC GetAllPatients;

--Q26
CREATE TABLE HighSalaryConsultantsStore (
    Id INT,
    [Name] NVARCHAR(150),
    Salary DECIMAL(18, 2)
)
INSERT INTO HighSalaryConsultantsStore
EXEC GetConsultantsByMinSalary @MinSalary = 50000

--Q27
CREATE TABLE WardPatientsStore (
    Id INT,
    [Name] NVARCHAR(150),
    DOB DATE,
    WardId INT
)
INSERT INTO WardPatientsStore
EXEC GetPatientsByWard_PR @WardId = 1

--Q28
CREATE TABLE PatientAudit (
    AuditId INT IDENTITY PRIMARY KEY,
    PatientId INT,
    ActionType NVARCHAR(50),
    ActionDate DATETIME DEFAULT GETDATE()
)

--Q29
CREATE OR ALTER TRIGGER trg_Patient_AfterInsert
ON Patients
AFTER INSERT
AS
BEGIN
    INSERT INTO PatientAudit (PatientId, ActionType)
    SELECT Id, 'INSERT' FROM inserted
END

--Q30
CREATE TABLE ConsultantSalaryAudit (
    AuditId INT IDENTITY PRIMARY KEY,
    ConsultantId INT,
    OldSalary DECIMAL(18, 2),
    NewSalary DECIMAL(18, 2),
    ModifiedDate DATETIME DEFAULT GETDATE()
)

CREATE OR ALTER TRIGGER trg_Consultant_SalaryUpdate
ON Consultants
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Salary)
    BEGIN
        INSERT INTO ConsultantSalaryAudit (ConsultantId, OldSalary, NewSalary)
        SELECT d.Id, d.Salary, i.Salary
        FROM deleted d
        INNER JOIN inserted i ON d.Id = i.Id
    END
END

--Q31
CREATE TABLE PatientWardAudit (
    AuditId INT IDENTITY PRIMARY KEY,
    PatientId INT,
    OldWardId INT,
    NewWardId INT,
    ChangeDate DATETIME DEFAULT GETDATE()
)

CREATE OR ALTER TRIGGER trg_Patient_WardUpdate
ON Patients
AFTER UPDATE
AS
BEGIN
    IF UPDATE(WardId)
    BEGIN
        INSERT INTO PatientWardAudit (PatientId, OldWardId, NewWardId)
        SELECT d.Id, d.WardId, i.WardId
        FROM deleted d
        INNER JOIN inserted i ON d.Id = i.Id
    END
END

--Q32
CREATE TABLE DeletedPatients (
    Id INT,
    [Name] NVARCHAR(150),
    DOB DATE,
    WardId INT,
    DeletedDate DATETIME DEFAULT GETDATE()
)

CREATE OR ALTER TRIGGER trg_Archive_DeletedPatients
ON Patients
AFTER DELETE
AS
BEGIN
    INSERT INTO DeletedPatients (Id, [Name], DOB, WardId)
    SELECT Id, [Name], DOB, WardId FROM deleted
END

--Q33
CREATE TABLE DeletedConsultants (
    Id INT,
    [Name] NVARCHAR(150),
    Salary DECIMAL(18, 2),
    DeletedDate DATETIME DEFAULT GETDATE()
)

CREATE OR ALTER TRIGGER trg_Archive_DeletedConsultants
ON Consultants
AFTER DELETE
AS
BEGIN
    INSERT INTO DeletedConsultants (Id, [Name], Salary)
    SELECT Id, [Name], Salary FROM deleted
END

--Q34
CREATE OR ALTER TRIGGER trg_Display_ConsultantSalaryChange
ON Consultants
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Salary)
    BEGIN
        SELECT d.Id AS ConsultantId, d.[Name], d.Salary AS OldSalary, i.Salary AS NewSalary
        FROM deleted d
        INNER JOIN inserted i ON d.Id = i.Id
    END
END

--Q35
CREATE OR ALTER TRIGGER trg_Display_PatientWardChange
ON Patients
AFTER UPDATE
AS
BEGIN
    IF UPDATE(WardId)
    BEGIN
        SELECT d.Id AS PatientId, d.[Name], d.WardId AS OldWardId, i.WardId AS NewWardId
        FROM deleted d
        INNER JOIN inserted i ON d.Id = i.Id
    END
END

--Q36
CREATE OR ALTER TRIGGER trg_Multiple_Patients_Insert
ON Patients
AFTER INSERT
AS
BEGIN
    INSERT INTO PatientAudit (PatientId, ActionType)
    SELECT Id, 'BULK INSERT' FROM inserted
END

--Q37
CREATE OR ALTER TRIGGER trg_PreventNullWard
ON Patients
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE WardId IS NULL)
    BEGIN
        RAISERROR('Cannot insert a patient without a Ward ID.', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Patients ([Name], DOB, WardId)
        SELECT [Name], DOB, WardId FROM inserted
    END
END

--Q38
CREATE OR ALTER TRIGGER trg_ValidatePatientDOB
ON Patients
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE DOB > CAST(GETDATE() AS DATE))
    BEGIN
        RAISERROR('Date of Birth cannot be in the future.', 16, 1)
    END
    ELSE
    BEGIN
        INSERT INTO Patients ([Name], DOB, WardId)
        SELECT [Name], DOB, WardId FROM inserted
    END
END

--Q39
CREATE OR ALTER TRIGGER trg_PreventSalaryReduction
ON Consultants
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted i 
        INNER JOIN deleted d ON i.Id = d.Id 
        WHERE i.Salary < d.Salary
    )
    BEGIN
        RAISERROR('Decreasing consultant salary is not allowed.', 16, 1)
    END
    ELSE
    BEGIN
        UPDATE c
        SET c.[Name] = i.[Name], c.Salary = i.Salary
        FROM Consultants c
        INNER JOIN inserted i ON c.Id = i.Id
    END
END

--Q40
CREATE OR ALTER TRIGGER trg_LockPatientIdUpdate
ON Patients
INSTEAD OF UPDATE
AS
BEGIN
    IF UPDATE(Id)
    BEGIN
        RAISERROR('Patient ID cannot be modified.', 16, 1)
    END
    ELSE
    BEGIN
        UPDATE p
        SET p.[Name] = i.[Name], p.DOB = i.DOB, p.WardId = i.WardId
        FROM Patients p
        INNER JOIN inserted i ON p.Id = i.Id
    END
END

--Q41
CREATE OR ALTER TRIGGER trg_PreventPatientDelete
ON Patients
INSTEAD OF DELETE
AS
BEGIN
    RAISERROR('Deletion of patient records is permanently prohibited.', 16, 1)
END

--Q42
CREATE OR ALTER TRIGGER trg_ArchiveBeforeDelete
ON Patients
INSTEAD OF DELETE
AS
BEGIN
    INSERT INTO DeletedPatients (Id, [Name], DOB, WardId)
    SELECT Id, [Name], DOB, WardId FROM deleted

    DELETE FROM Patients WHERE Id IN (SELECT Id FROM deleted)
END

--Q43 
CREATE OR ALTER PROCEDURE AddPatientWithAudit
    @Name NVARCHAR(150),
    @DOB DATE,
    @WardId INT
AS
BEGIN
    INSERT INTO Patients ([Name], DOB, WardId)
    VALUES (@Name, @DOB, @WardId)
END

--Q44
CREATE OR ALTER PROCEDURE UpdateConsultantSalaryAudit
    @ConsultantId INT,
    @NewSalary DECIMAL(18, 2)
AS
BEGIN
    UPDATE Consultants
    SET Salary = @NewSalary
    WHERE Id = @ConsultantId
END

--Q45
CREATE OR ALTER PROCEDURE DeletePatientAndArchive
    @PatientId INT
AS
BEGIN
    DELETE FROM Patients WHERE Id = @PatientId
END

--Q46
CREATE OR ALTER PROCEDURE TransferPatientAndMedicate
    @PatientId INT,
    @NewWardId INT,
    @NurseId INT,
    @DrugCode INT,
    @Dosage NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
            UPDATE Patients 
            SET WardId = @NewWardId 
            WHERE Id = @PatientId

            INSERT INTO DrugAdministrations (NurseId, DrugCode, PatientId, Dosage, [DATE], [Time])
            VALUES (@NurseId, @DrugCode, @PatientId, @Dosage, CAST(GETDATE() AS DATE), CAST(GETDATE() AS TIME))
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE() AS [Transaction Error]
    END CATCH
END

--Q47
CREATE TABLE CompletePatientAudit (
    AuditId INT IDENTITY PRIMARY KEY,
    PatientId INT,
    OperationType NVARCHAR(10),
    OperationDate DATETIME DEFAULT GETDATE()
)

CREATE OR ALTER TRIGGER trg_CompletePatientAudit
ON Patients
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
        INSERT INTO CompletePatientAudit (PatientId, OperationType) SELECT Id, 'INSERT' FROM inserted

    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
        INSERT INTO CompletePatientAudit (PatientId, OperationType) SELECT Id, 'DELETE' FROM deleted

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        INSERT INTO CompletePatientAudit (PatientId, OperationType) SELECT Id, 'UPDATE' FROM inserted
END

--Q48
CREATE OR ALTER PROCEDURE GetHospitalStats
AS
BEGIN
    SELECT 
        (SELECT COUNT(Id) FROM Patients) AS TotalPatients,
        (SELECT COUNT(Id) FROM Consultants) AS TotalConsultants,
        (SELECT AVG(Salary) FROM Consultants) AS AvgConsultantSalary,
        (SELECT COUNT(DrugCode) FROM DrugAdministrations) AS TotalMedicationsGiven
END

--Q49
CREATE OR ALTER PROCEDURE GetPatientMedicationStatsSafe
    @PatientId INT,
    @TotalDosagesCount INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SELECT @TotalDosagesCount = COUNT(DrugCode)
        FROM DrugAdministrations
        WHERE PatientId = @PatientId
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END

--Q50
CREATE OR ALTER PROCEDURE GetFinalPatientSummary
    @PatientId INT
AS
BEGIN
    BEGIN TRY
        SELECT 
            p.Id AS PatientId,
            p.[Name] AS PatientName,
            w.[Name] AS WardName,
            COUNT(da.DrugCode) AS TotalAdministrations,
            COUNT(da.DrugCode) AS TotalQuantityCount
        FROM Patients p
        LEFT JOIN Wards w ON p.WardId = w.Id
        LEFT JOIN DrugAdministrations da ON p.Id = da.PatientId
        WHERE p.Id = @PatientId
        GROUP BY p.Id, p.[Name], w.[Name]
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage
    END CATCH
END