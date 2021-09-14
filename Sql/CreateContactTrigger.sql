USE GigiPhotographyDevelopment
GO 

CREATE OR ALTER TRIGGER TR_Contact_After_Insert_Or_Update
ON 
	dbo.Contact AFTER INSERT, UPDATE AS
BEGIN

	IF(ROWCOUNT_BIG() = 0)
	BEGIN
		RETURN;
	END;

	SET NOCOUNT ON;

	
	IF NOT EXISTS(SELECT * FROM INSERTED)
		RETURN;
	PRINT('Gathering inserted data')
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

		IF NOT EXISTS(SELECT * FROM DELETED)
			RETURN;
		PRINT('Gathering Updated Data')
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
END;

