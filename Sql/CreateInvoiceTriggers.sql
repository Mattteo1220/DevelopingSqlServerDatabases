USE GigiPhotographyDevelopment
GO 

--======================Invoice=================================--
CREATE OR ALTER TRIGGER TR_Invoice_After_Insert_or_Delete_or_Update
ON 
	dbo.Invoice AFTER INSERT, DELETE, UPDATE
AS 
BEGIN
	IF (ROWCOUNT_BIG() = 0)
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
		SELECT * INTO #InsertedInvoiceData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT
			SELECT * FROM DELETED
		) InsertedInvoiceData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Invoice', i1.InvoiceId, i2.NewValues
		FROM 
			#InsertedInvoiceData i1
		CROSS APPLY
		(
			SELECT NewValues = (SELECT * FROM #InsertedInvoiceData WHERE #InsertedInvoiceData.InvoiceId = i1.InvoiceId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedInvoiceData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedInvoiceData
		INSERT INTO dbo.AuditLog 
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Invoice', m1.InvoiceId, m2.OldValues
		FROM 
			#ModifiedInvoiceData m1
		CROSS APPLY 
		(
			SELECT oldValues = (SELECT * FROM #ModifiedInvoiceData WHERE #ModifiedInvoiceData.InvoiceId = m1.InvoiceId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS m2
	END
	DROP TABLE IF EXISTS #InsertedInvoiceData
	DROP TABLE IF EXISTS #ModifiedInvoiceData
END
GO 

CREATE OR ALTER TRIGGER TR_Event_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Event] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedEventData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedEventData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Event', i1.EventId, i2.NewValues
		FROM 
			#InsertedEventData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedEventData WHERE #InsertedEventData.EventId = i1.EventId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedEventData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedEventData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Event', m1.EventId, m2.OldValues
		FROM 
			#ModifiedEventData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedEventData WHERE #ModifiedEventData.EventId = m1.EventId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedEventData
	DROP TABLE IF EXISTS #ModifiedEventData
END
GO 

CREATE OR ALTER TRIGGER TR_Communication_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Communication] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedCommunicationData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedEventData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Communication', i1.CommunicationId, i2.NewValues
		FROM 
			#InsertedCommunicationData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedCommunicationData WHERE #InsertedCommunicationData.CommunicationId = i1.CommunicationId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedCommunicationData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedCommunicationData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Communication', m1.CommunicationId, m2.OldValues
		FROM 
			#ModifiedCommunicationData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedCommunicationData WHERE #ModifiedCommunicationData.CommunicationId = m1.CommunicationId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedCommunicationData
	DROP TABLE IF EXISTS #ModifiedCommunicationData
END
GO 


CREATE OR ALTER TRIGGER TR_Site_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Site] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedSiteData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedSiteData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Site', i1.SiteId, i2.NewValues
		FROM 
			#InsertedSiteData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedSiteData WHERE #InsertedSiteData.SiteId = i1.SiteId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedSiteData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedSiteData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Site', m1.SiteId, m2.OldValues
		FROM 
			#ModifiedSiteData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedSiteData WHERE #ModifiedSiteData.SiteId = m1.SiteId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedSiteData
	DROP TABLE IF EXISTS #ModifiedSiteData
END
GO 

CREATE OR ALTER TRIGGER TR_Photographer_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Photographer] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedPhotographerData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedPhotographerData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Photographer', i1.PhotographerId, i2.NewValues
		FROM 
			#InsertedPhotographerData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedPhotographerData WHERE #InsertedPhotographerData.PhotographerId = i1.PhotographerId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedPhotographereData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedPhotographerData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Photographer', m1.PhotographerId, m2.OldValues
		FROM 
			#ModifiedPhotographerData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedPhotographerData WHERE #ModifiedPhotographerData.PhotographerId = m1.PhotographerId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedPhotographerData
	DROP TABLE IF EXISTS #ModifiedPhotographereData
END
GO 

CREATE OR ALTER TRIGGER TR_Rate_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Rate] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedRateData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedRateData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Rate', i1.RateId, i2.NewValues
		FROM 
			#InsertedRateData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedRateData WHERE #InsertedRateData.RateId = i1.RateId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedRateData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedRateData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Rate', m1.RateId, m2.OldValues
		FROM 
			#ModifiedRateData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedRateData WHERE #ModifiedRateData.RateId = m1.RateId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedRateData
	DROP TABLE IF EXISTS #ModifiedRateData
END
GO 

CREATE OR ALTER TRIGGER TR_Category_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Category] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedCategoryData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedCategoryData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Category', i1.CategoryId, i2.NewValues
		FROM 
			#InsertedCategoryData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedCategoryData WHERE #InsertedCategoryData.CategoryId = i1.CategoryId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedCategoryData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedCategoryData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Category', m1.CategoryId, m2.OldValues
		FROM 
			#ModifiedCategoryData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedCategoryData WHERE #ModifiedCategoryData.CategoryId = m1.CategoryId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedCategoryData
	DROP TABLE IF EXISTS #ModifiedCategoryData
END
GO 

CREATE OR ALTER TRIGGER TR_State_After_Insert_or_Delete_or_Update
ON 
	[dbo].[State] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedStateData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedStateData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'State', i1.StateId, i2.NewValues
		FROM 
			#InsertedStateData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedStateData WHERE #InsertedStateData.StateId = i1.StateId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedStateData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedStateData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'State', m1.StateId, m2.OldValues
		FROM 
			#ModifiedStateData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedStateData WHERE #ModifiedStateData.StateId = m1.StateId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedStateData
	DROP TABLE IF EXISTS #ModifiedStateData
END
GO 

CREATE OR ALTER TRIGGER TR_Payment_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Payment] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedPaymentData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedPaymentData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Payment', i1.PaymentId, i2.NewValues
		FROM 
			#InsertedPaymentData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedPaymentData WHERE #InsertedPaymentData.PaymentId = i1.PaymentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedPaymentData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedPaymentData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Payment', m1.PaymentId, m2.OldValues
		FROM 
			#ModifiedPaymentData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedPaymentData WHERE #ModifiedPaymentData.PaymentId = m1.PaymentId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedPaymentData
	DROP TABLE IF EXISTS #ModifiedPaymentData
END
GO 

CREATE OR ALTER TRIGGER TR_PaymentMethod_After_Insert_or_Delete_or_Update
ON 
	[dbo].[PaymentMethod] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedPaymentMethodData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedPaymentMethodData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'PaymentMethod', i1.PaymentMethodId, i2.NewValues
		FROM 
			#InsertedPaymentMethodData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedPaymentMethodData WHERE #InsertedPaymentMethodData.PaymentMethodId = i1.PaymentMethodId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedPaymentMethodData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedPaymentMethodData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'PaymentMethod', m1.PaymentMethodId, m2.OldValues
		FROM 
			#ModifiedPaymentMethodData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedPaymentMethodData WHERE #ModifiedPaymentMethodData.PaymentMethodId = m1.PaymentMethodId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedPaymentMethodData
	DROP TABLE IF EXISTS #ModifiedPaymentMethodData
END
GO 


CREATE OR ALTER TRIGGER TR_Session_After_Insert_or_Delete_or_Update
ON 
	[dbo].[Session] AFTER INSERT, DELETE, UPDATE 
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
		SELECT * INTO #InsertedSessionData FROM 
		(
			SELECT * FROM INSERTED 
			EXCEPT 
			SELECT * FROM DELETED
		) InsertedSessionData
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Session', i1.SessionId, i2.NewValues
		FROM 
			#InsertedSessionData i1
		CROSS APPLY 
		(
			SELECT NewValues = (SELECT * FROM #InsertedSessionData WHERE #InsertedSessionData.SessionId = i1.SessionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) AS i2
	END
	ELSE
	BEGIN
		SELECT * INTO #ModifiedSessionData FROM 
		(
			SELECT * FROM DELETED
			EXCEPT
			SELECT * FROM INSERTED
		) ModifiedSessionData 
		INSERT INTO dbo.AuditLog
			(ModifiedAt, ModifiedBy, Operation, SchemaName, TableName, Identifier, LogData)
		SELECT 
			GETDATE(), SYSTEM_USER, @OperationType, 'Dbo', 'Session', m1.SessionId, m2.OldValues
		FROM 
			#ModifiedSessionData m1
		CROSS APPLY 
		(
			SELECT OldValues = (SELECT * FROM #ModifiedSessionData WHERE #ModifiedSessionData.SessionId = m1.SessionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
		) m2
	END
	DROP TABLE IF EXISTS #InsertedSessionData
	DROP TABLE IF EXISTS #ModifiedSessionData
END
GO 
