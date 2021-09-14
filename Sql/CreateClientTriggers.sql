USE GigiPhotographyDevelopment
GO

CREATE OR ALTER TRIGGER TR_Client_After_Update_Or_Insert_Or_Delete
ON 
	[dbo].[Client] AFTER INSERT, UPDATE, DELETE AS 
BEGIN 
	IF(ROWCOUNT_BIG() = 0)
	BEGIN
		RETURN;
	END;

	SET NOCOUNT ON;

	DECLARE @OperationType varchar(42)
	IF EXISTS(SELECT * FROM inserted)
	  IF EXISTS(SELECT * FROM deleted)
	    SELECT @OperationType = 'UPDATE'
	ELSE
	    SELECT @OperationType = 'INSERT'
	ELSE
	  IF EXISTS(SELECT * FROM deleted)
	    SELECT @OperationType = 'DELETE'
	  ELSE
	    --no rows affected - cannot determine event
	    SELECT @OperationType = 'UNKNOWN'

	IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		SELECT * INTO #InsertedData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT
			SELECT * FROM DELETED
		) InsertedData
		INSERT INTO dbo.ClientAuditLog 
		(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Client', i1.ClientId, i2.OldValues
		FROM 
			#InsertedData i1
		CROSS APPLY
		(
			SELECT oldValues = (SELECT * FROM #InsertedData WHERE #InsertedData.ClientId = i1.ClientId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
			SELECT * INTO #ModifiedData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedData;

		INSERT INTO dbo.ClientAuditLog 
		(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT
		GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Client', m1.ClientId, m2.OldValues
		FROM 
			#ModifiedData m1
		CROSS APPLY
		(
			SELECT oldValues = (SELECT * FROM #ModifiedData WHERE #ModifiedData.ClientId = M1.ClientId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS M2
	END

END

CREATE OR ALTER TRIGGER TR_Contact_After_Insert_Update_Or_Delete
ON 
	dbo.Contact 