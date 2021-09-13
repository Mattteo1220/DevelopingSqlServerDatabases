USE GigiPhotographyDevelopment
GO 

DROP TABLE IF EXISTS dbo.ContactHistory, dbo.Contact, dbo.ContactMethod, dbo.Client 

BEGIN TRY
BEGIN TRANSACTION CreateClientContact

CREATE TABLE Client(
	ClientId INT IDENTITY(1,1) NOT NULL 
		CONSTRAINT PK_Client_ClientID PRIMARY KEY,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL
	)

CREATE TABLE ContactMethod(
	ContactMethodId INT IDENTITY(0, 1) 
		CONSTRAINT PK_ContactMethod_ContactMethodId PRIMARY KEY,
	[Description] NVARCHAR(25) NOT NULL
	)

CREATE TABLE Contact(
	ContactId INT IDENTITY(1,1) NOT NULL
		CONSTRAINT PK_Contact_ContactId PRIMARY KEY,
	Client INT NOT NULL
		CONSTRAINT FK_Contact_Client_Client_ClientId 
			FOREIGN KEY REFERENCES dbo.Client(ClientId),
	Email NVARCHAR(250) NOT NULL
		CONSTRAINT UQ_Contact_Email
			UNIQUE NONCLUSTERED,
	Mobile NVARCHAR(12) NOT NULL
		CONSTRAINT UQ_Contact_Mobile
			UNIQUE NONCLUSTERED,
	ContactMethod INT NOT NULL 
		CONSTRAINT FK_Contact_ContactMethod_ContactMethod_ContactMethodId
			FOREIGN KEY REFERENCES dbo.ContactMethod (ContactMethodId),
	CreatedDate DATETIME2 NOT NULL,
	CreatedBy NVARCHAR(100) NOT NULL
	)

CREATE TABLE ContactHistory(
	ContactHistoryId INT IDENTITY(1,1) NOT NULL
		CONSTRAINT PK_ContactHistory_ContactHistoryId PRIMARY KEY,
	Contact INT NOT NULL 
		CONSTRAINT FK_ContactHistory_Contact_Contact_ContactId 
			FOREIGN KEY REFERENCES dbo.Contact(ContactId),
	Email NVARCHAR(250) NOT NULL,
	Mobile NVARCHAR(12) NOT NULL,
	ContactMethod INT NOT NULL,
	CreatedDate DATETIME2 NOT NULL,
	CreatedBy NVARCHAR(100) NOT NULL
)

COMMIT TRANSACTION CreateClientContact
END TRY 
BEGIN CATCH 

WHILE (@@TRANCOUNT > 0)
BEGIN;
	ROLLBACK TRANSACTION
END;

SELECT
    ERROR_NUMBER() AS ErrorNumber,
    ERROR_STATE() AS ErrorState,
    ERROR_SEVERITY() AS ErrorSeverity,
    ERROR_PROCEDURE() AS ErrorProcedure,
    ERROR_LINE() AS ErrorLine,
    ERROR_MESSAGE() AS ErrorMessage;
END CATCH