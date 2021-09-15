USE GigiPhotographyDevelopment
GO 

--=====================================================--
--======================TypeTrigger====================--
CREATE OR ALTER TRIGGER TR_Type_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Type] AFTER INSERT, UPDATE, DELETE 
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
		RETURN;

	SET NOCOUNT ON;

	DECLARE @OperationType NVARCHAR(20);
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
		SELECT * INTO #InsertedTypeData FROM 
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		) InsertedTypeData
		INSERT INTO dbo.AuditLog 
		(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Type', i1.TypeId, i2.NewValues
		FROM 
			#InsertedTypeData i1
		CROSS APPLY
		(
			SELECT NewValues = (SELECT * FROM #InsertedTypeData WHERE #InsertedTypeData.TypeId = i1.TypeId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedTypeData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedTypeData
		INSERT INTO dbo.AuditLog
		(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Type', m1.TypeId, m2.OldValues
		FROM 
			#ModifiedTypeData m1	
		CROSS APPLY
		(
			SELECT OldValues = (SELECT * FROM #ModifiedTypeData WHERE #ModifiedTypeData.TypeId = m1.TypeId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS m2
	END
	DROP TABLE IF EXISTS #InsertedTypeData
	DROP TABLE IF EXISTS #ModifiedTypeData
END
GO 

--=====================================================--
--======================Verification====================--
CREATE OR ALTER TRIGGER TR_Verification_After_Insert_or_Delete_or_Update
ON 
	dbo.Verification AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
		RETURN;

	SET NOCOUNT ON;

	DECLARE @OperationType NVARCHAR(20);

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
		SELECT * INTO #InsertedVerificationData FROM 
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		) InsertedVerificationData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Verification', i1.VerificationId, i2.NewValues
		FROM 
			#InsertedVerificationData i1
		CROSS APPLY
		(
			SELECT NewValues = (SELECT * FROM #InsertedVerificationData WHERE #InsertedVerificationData.VerificationId = i1.VerificationId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) i2;
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedVerificationData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedVerificationData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Verification', m1.VerificationId, m2.OldValues
		FROM 
			#ModifiedVerificationData m1
		CROSS APPLY
		(
			SELECT OldValues = (SELECT * FROM #ModifiedVerificationData WHERE #ModifiedVerificationData.VerificatinId = i1.VerificationId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedVerificationData
	DROP TABLE IF EXISTS #ModifiedVerificationData
END
GO 

--=====================================================--
--======================Role====================--
CREATE OR ALTER TRIGGER TR_Role_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Role] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedRoleData FROM 
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		) InsertedRoleData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Role', i1.RoleId, i2.NewValues
		FROM 
			#InsertedRoleData i1
		CROSS APPLY 
		(	
			SELECT NewValues = (SELECT * FROM #InsertedRoleData WHERE #InsertedRoleData.RoleId = i1.RoleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedRoleData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedRoleData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Role', m1.RoleId, m2.oldValues
		FROM 
			#ModifiedRoleData m1
		CROSS APPLY
		(
			SELECT oldValues = (SELECT * FROM #ModifiedRoleData WHERE #ModifiedRoleData.RoleId = m1.RoleId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedRoleData
	DROP TABLE IF EXISTS #ModifiedRoleData
END
GO

--=====================================================--
--======================Promotion====================--
CREATE OR ALTER TRIGGER TR_Promotion_After_Insert_or_Delete_or_Update
ON 
	dbo.Promotion AFTER INSERT, DELETE, UPDATE 
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
		RETURN;

	SET NOCOUNT ON 

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
		SELECT * INTO #InsertedPromotionData FROM 
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		) InsertedPromotionData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Promotion', i1.PromotionId, i2.NewValues
		FROM 
			#InsertedPromotionData i1
		CROSS APPLY
		(
			SELECT NewValues = (SELECT * FROM #InsertedPromotionData WHERE #InsertedPromotionData.PromotionId = i1.PromotionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedPromotionData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedPromotionData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Promotion', m1.PromotionId, m2.OldValues
		FROM 
			#ModifiedPromotionData m1
		CROSS APPLY
		(
			SELECT OldValues = (SELECT * FROM #ModifiedPromotionData WHERE #ModifiedPromotionData.PromotionId = m1.PromotionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedPromotionData
	DROP TABLE IF EXISTS #ModifiedPromotionData
END
GO

CREATE OR ALTER TRIGGER TR_Login_After_Insert_or_Delete_or_Update
ON 
	dbo.Login AFTER INSERT, DELETE, UPDATE 
AS 
BEGIN
	IF(ROWCOUNT_BIG() = 0)
		RETURN;

	SET NOCOUNT ON 

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

	IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		SELECT * INTO #InsertedLoginData FROM 
		(
			SELECT * FROM INSERTED
			EXCEPT
			SELECT * FROM DELETED
		) InsertedLoginData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Login', i1.LoginId, i2.NewValues
		FROM 
			#InsertedLoginData i1
		CROSS APPLY
		(
			SELECT NewValues = (SELECT * FROM #InsertedLoginData WHERE #InsertedLoginData.LoginId = i1.LoginId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedLoginData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedLoginData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Login', m1.LoginId, m2.OldValues
		FROM 
			#ModifiedLoginData m1
		CROSS APPLY
		(
			SELECT OldValues = (SELECT * FROM #ModifiedLoginData WHERE #ModifiedLoginData.LoginId = m1.LoginId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		)m2
	END
	DROP TABLE IF EXISTS #InsertedLoginData
	DROP TABLE IF EXISTS #ModifiedLoginData
END
GO 


