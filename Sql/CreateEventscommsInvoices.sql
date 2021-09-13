USE GigiPhotographyDevelopment
GO 



BEGIN TRY 
DROP TABLE IF EXISTS dbo.Invoice, dbo.Event, dbo.Communication, dbo.Site, dbo.Photographer, dbo.Rate, dbo.Category, dbo.State, dbo.Payment, dbo.PaymentMethod, dbo.Communication, dbo.Session

BEGIN TRANSACTION CreateEventsCommsInvoices

CREATE TABLE dbo.Site
(
	SiteId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Site_SiteId PRIMARY KEY,
	Name NVARCHAR(250) NOT NULL
		CONSTRAINT UQ_Site_Name
			UNIQUE NONCLUSTERED,
	Address NVARCHAR(250) NOT NULL
		CONSTRAINT UQ_Site_Address
			UNIQUE NONCLUSTERED
)

CREATE TABLE Dbo.Event
(
	EventId INT NOT NULL
		CONSTRAINT PK_Event_EventId PRIMARY KEY,
	Client INT NOT NULL
		CONSTRAINT FK_Event_Client_Client_ClientId
			FOREIGN KEY REFERENCES dbo.Client(ClientId),
	Site INT NOT NULL
		CONSTRAINT FK_Event_Site_Site_SiteId
			FOREIGN KEY REFERENCES dbo.Site(SiteId),
	PhotosReleased BIT NOT NULL
		CONSTRAINT DF_Event_PhotosReleased
			DEFAULT 0,
	CreatedAt DATETIME2 NOT NULL
		CONSTRAINT DF_Event_CreatedAt DEFAULT GETDATE(),
	CreatedBy NVARCHAR(250) NOT NULL
)

CREATE TABLE dbo.Photographer
(
	PhotographerId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Photographer_PhotographerId PRIMARY KEY,
	Client INT NOT NULL
		CONSTRAINT FK_Photographer_Client_ClientId 
			FOREIGN KEY REFERENCES dbo.Client(ClientId),
	Contact INT NOT NULL
		CONSTRAINT FK_Photographer_Contact_Contact_ContactId
			FOREIGN KEY REFERENCES dbo.Contact(ContactId)
)

CREATE TABLE dbo.Category
(
	CategoryId INT NOT NULL IDENTITY(0,1)
		CONSTRAINT PK_Category_CategoryId PRIMARY KEY,
	Description NVARCHAR(50) NOT NULL
)

CREATE TABLE dbo.Rate
(
	RateId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Rate_RateId PRIMARY KEY,
	Category INT NOT NULL 
		CONSTRAINT FK_Rate_Category_Category_CategoryId
			FOREIGN KEY REFERENCES dbo.Category(CategoryId),
	Rate DECIMAL(7,2) NOT NULL
)

CREATE TABLE dbo.State 
(
	StateId INT NOT NULL IDENTITY(0,1)
		CONSTRAINT PK_State_StateId PRIMARY KEY,
	Description NVARCHAR(50) NOT NULL
)

CREATE TABLE PaymentMethod
(
	PaymentMethodId INT NOT NULL IDENTITY(0,1)
		CONSTRAINT PK_PaymentMethod_PaymentMethodId PRIMARY KEY,
	Description NVARCHAR(25) NOT NULL
)

CREATE TABLE dbo.Payment 
(
	PaymentId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Payment_PaymentId PRIMARY KEY,
	PaymentMethod INT NOT NULL
		CONSTRAINT FK_Payment_PaymentMethod_PaymentMethod_PaymentMethodId
			FOREIGN KEY REFERENCES dbo.PaymentMethod(PaymentMethodId),
	PaidOn DATETIME2 NOT NULL
)

CREATE TABLE dbo.Invoice 
(
	InvoiceId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Invoice_InvoiceId PRIMARY KEY,
	Event INT NOT NULL
		CONSTRAINT FK_Invoice_Event_Event_EventId
			FOREIGN KEY REFERENCES dbo.Event(EventId),
	Rate INT NOT NULL
		CONSTRAINT FK_Invoice_Rate_Rate_RateId 
			FOREIGN KEY REFERENCES dbo.Rate(RateId),
	Total DECIMAL(7,2) NOT NULL,
	Payment INT NULL
		CONSTRAINT FK_Invoice_Payment_Payment_PaymentId
			FOREIGN KEY REFERENCES dbo.Payment(PaymentId)
		CONSTRAINT DF_Invoice_Payment 
			DEFAULT NULL
)

CREATE TABLE dbo.Communication
(
	CommunicationId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Communication_CommunicationId PRIMARY KEY,
	Event INT NOT NULL
		CONSTRAINT FK_Communication_Event_Event_EventId 
			FOREIGN KEY REFERENCES dbo.Event(EventId),
	Channel INT NOT NULL
		CONSTRAINT FK_Communication_Channel_Channel_ChannelId
			FOREIGN KEY REFERENCES dbo.Channel(ChannelId),
	CreatedAt DATETIME2 NOT NULL
		CONSTRAINT DF_Communication_CreatedAt DEFAULT GETDATE(),
	CreatedBy NVARCHAR(250) NOT NULL
)

CREATE TABLE dbo.Session
(
	SessionId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Session_SessionId PRIMARY KEY,
	Event INT NOT NULL
		CONSTRAINT FK_Session_Event_Event_EventId
			FOREIGN KEY REFERENCES dbo.Event(EventId),
	Category INT NOT NULL
		CONSTRAINT FK_Session_Category_Category_CategoryId
			FOREIGN KEY REFERENCES dbo.Category(CategoryId),
	Rate INT NOT NULL
		CONSTRAINT FK_Session_Rate_Rate_RateId 
			FOREIGN KEY REFERENCES Dbo.Rate(RateId),
	Photographer INT NOT NULL
		CONSTRAINT FK_Session_Photographer_Photographer_PhotographerId
			FOREIGN KEY REFERENCES dbo.Photographer(PhotographerId),
	Invoice INT NOT NULL
		CONSTRAINT FK_Session_Invoice_Invoice_InvoiceId
			FOREIGN KEY REFERENCES dbo.Invoice(InvoiceId),
	State INT NOT NULL
		CONSTRAINT FK_Session_State_State_StateId
			FOREIGN KEY REFERENCES dbo.State(StateId),
	DateOfSession DATETIME2 NOT NULL,
	CreatedAt DATETIME2 NOT NULL
		CONSTRAINT DF_Session_CreatedAt 
			DEFAULT GETDATE(),
	CreatedBy NVARCHAR(100) NOT NULL
)


COMMIT TRANSACTION CreateEventsCommsInvoices
END TRY 

BEGIN CATCH
WHILE(@@TRANCOUNT > 0)
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