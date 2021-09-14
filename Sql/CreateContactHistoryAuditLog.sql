USE GigiPhotographyDevelopment
GO 

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