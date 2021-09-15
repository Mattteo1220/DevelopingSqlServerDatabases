USE GigiPhotographyDevelopment
GO 

CREATE OR ALTER TRIGGER TR_ContactMethod_After_Insert_or_Update_or_Delete
ON 
	dbo.ContactMethod AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
		RETURN;

	SET NOCOUNT ON;

	DECLARE @OperationType NVARCHAR(20)

	IF EXISTS(SELECT * FROM INSERTED)
		IF EXISTS(SELECT * FROM DELETED)
			SET @OperationType = 'UPDATE'
		ELSE
			SET @OperationType = 'INSERT'
	ELSE
		IF EXISTS(SELECT * FROM DELETED)
			SET @OperationType = 'DELETE'
		ELSE
			SET @OperationType = 'UNKNOWN'

	IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		SELECT * INTO #InsertedContactMethodData FROM
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		)InsertedContactMethodData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'ContactMethod', i1.ContactMethodId, i2.NewValue
		FROM 
			#InsertedContactMethodData i1
		CROSS APPLY
		(
			SELECT NewValue = (SELECT * FROM #InsertedContactMethodData WHERE #InsertedContactMethodData.ContactMethodId = i1.ContactMethodId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedContactMethodData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedContactMethodData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'ContactMethod', m1.ContactMethodId, m2.OldValues
		FROM 
			#ModifiedContactMethodData m1
		CROSS APPLY
		(
			SELECT OldValues = (SELECT * FROM #ModifiedContactMethodData WHERE #ModifiedContactMethodData.ContactMethodId = i1.ContactMethodId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		)AS m2
	END
END
GO 

