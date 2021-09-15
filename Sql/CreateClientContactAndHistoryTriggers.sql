USE GigiPhotographyDevelopment
GO

--==============================================================--
--=====================ClientTrigger============================--
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
		INSERT INTO dbo.AuditLog 
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

		INSERT INTO dbo.AuditLog 
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
GO 

--=========================================================--
--======================ContactTrigger=====================--
CREATE OR ALTER TRIGGER TR_Contact_After_Insert_Or_Update
ON 
	dbo.Contact AFTER INSERT, UPDATE AS
BEGIN

	IF(ROWCOUNT_BIG() = 0)
	BEGIN
		RETURN;
	END;

	SET NOCOUNT ON;

	IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		PRINT('Gathering inserted Contact data')
		SELECT * INTO #InsertedData FROM 
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		)	InsertedData
		INSERT INTO dbo.ContactHistory 
		(Contact, Email, Mobile, ContactMethod, CreatedDate, CreatedBy)
		SELECT
			i1.ContactId, i1.Email, i1.Mobile, i1.ContactMethod, i1.CreatedDate, i1.CreatedBy
		FROM 
			#InsertedData i1
	END
	ELSE
	BEGIN
		PRINT('Gathering Updated Contact Data')
		SELECT * INTO #ModifiedData FROM 
		(
			SELECT * FROM DELETED 
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedData
		INSERT INTO dbo.ContactHistory
		(Contact, Email, Mobile, ContactMethod, CreatedDate, CreatedBy)
		SELECT
				M1.ContactId, M1.Email, M1.Mobile, M1.ContactMethod, M1.CreatedDate, M1.CreatedBy
		FROM 
			#ModifiedData M1
	END
END;
GO

--==================================================================--
--====================ContactHistoryTrigger=========================--
CREATE OR ALTER TRIGGER TR_ContactHistory_After_Update_Insert_Delete
ON 
	dbo.ContactHistory AFTER INSERT, UPDATE, DELETE AS 
BEGIN
	IF (ROWCOUNT_BIG() = 0)
		RETURN;

	SET NOCOUNT ON

	DECLARE @OperationType NVARCHAR(16)

	IF EXISTS(SELECT * FROM INSERTED)
		IF EXISTS(SELECT * FROM DELETED)
			SET @OperationType = 'UPDATE'
		ELSE
			SET @OperationType = 'INSERT'
	ELSE
		IF EXISTS(SELECT * FROM DELETED)
			SET @OperationType = 'DELETE'
		ELSE
			SET @OperationType = 'UNKONWN'

	IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED)
	BEGIN
		SELECT * INTO #ContactHistoryInsertedData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT
			SELECT * FROM DELETED
		) ContactHistoryInsertedData
		INSERT INTO dbo.AuditLog
		(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'ContactHistory', i1.Contact, i2.[Values]
		FROM 
			#ContactHistoryInsertedData i1
		CROSS APPLY
		(
			SELECT [Values] = (SELECT * FROM #ContactHistoryInsertedData WHERE #ContactHistoryInsertedData.Contact = i1.Contact FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ContactHistoryModifiedData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT 
			SELECT * FROM INSERTED
		) ContactHistoryModifiedData
		INSERT INTO dbo.AuditLog
		(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'ContactHistory', m1.Contact, m2.OldValues
		FROM 
			#ContactHistoryModifiedData m1
		CROSS APPLY 
		(
			SELECT oldValues = (SELECT * FROM #ContactHistoryModifiedData WHERE #ContactHistoryModifiedData.Contact = m1.Contact FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS m2
		
	END
END
GO 

--====================================================================--
--======================ContactMethod=================================--
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
			SELECT OldValues = (SELECT * FROM #ModifiedContactMethodData WHERE #ModifiedContactMethodData.ContactMethodId = m1.ContactMethodId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		)AS m2
	END
END
GO 

