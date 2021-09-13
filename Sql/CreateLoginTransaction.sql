USE GigiPhotographyDevelopment
GO 

DROP TABLE IF EXISTS dbo.Verification, dbo.LockOut, dbo.Attempt, dbo.Login, dbo.Type, dbo.[Role]

BEGIN TRY 
BEGIN TRANSACTION CreateLogin


CREATE TABLE dbo.Type
(
	TypeId INT NOT NULL IDENTITY(0,1)
		CONSTRAINT PK_Type_TypeId PRIMARY KEY,
	Description NVARCHAR(250) NOT NULL,
)

CREATE TABLE dbo.Role 
(
	RoleId INT NOT NULL IDENTITY(0,1)
		CONSTRAINT PK_Role_RoleId PRIMARY KEY,
	Description NVARCHAR(25) NOT NULL
)

CREATE TABLE dbo.Login
(
	LoginId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Login_LoginId PRIMARY KEY,
	Client INT NOT NULL
		CONSTRAINT FK_Login_Client_Client_ClientId 
			FOREIGN KEY REFERENCES dbo.Client(ClientId),
	[Role] INT NOT NULL
		CONSTRAINT FK_Login_Role_Role_RoleId 
			FOREIGN KEY REFERENCES dbo.Role(RoleId),
	Username NVARCHAR(250) NOT NULL
		CONSTRAINT UQ_Login_Username
			UNIQUE NONCLUSTERED,
	Password NVARCHAR(250) NOT NULL
		CONSTRAINT UQ_Login_Password
			UNIQUE NONCLUSTERED,
	[Enabled] BIT NOT NULL,
	[Type] INT NOT NULL 
		CONSTRAINT FK_Login_Type_Type_TypeId 
			FOREIGN KEY REFERENCES dbo.Type(TypeId)
)

CREATE TABLE dbo.Attempt
(
	AttemptId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_Attempt_AttemptId PRIMARY KEY,
	Login INT NOT NULL
		CONSTRAINT FK_Attempt_Login_Login_LoginId 
			FOREIGN KEY REFERENCES dbo.Login(LoginId),
	IsSuccessful BIT NOT NULL,
	AttemptedAt DATETIME2 
		CONSTRAINT DF_Attempt_AttemptedAt DEFAULT GETDATE(),
	IPAddress NVARCHAR(250) NOT NULL
)

CREATE TABLE dbo.Lockout 
(
	LockOutId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_LockOut_LockOutId PRIMARY KEY,
	Login INT NOT NULL
		CONSTRAINT FK_LockOut_Login_Login_LoginId 
			FOREIGN KEY REFERENCES dbo.Login(LoginId),
	Duration DATETIME2 NOT NULL,
	LockOutDate DATETIME2 NOT NULL
)

CREATE TABLE dbo.Verification
(
	SecurityQuestionId INT NOT NULL IDENTITY(1,1)
		CONSTRAINT PK_SecurityQuestion_SecurityQuestionId PRIMARY KEY,
	Login INT NOT NULL
		CONSTRAINT FK_SecurityQuestion_Login_Login_LoginId 
			FOREIGN KEY REFERENCES dbo.[Login](LoginId),
	Question NVARCHAR(1000) NOT NULL,
	Answer NVARCHAR(1000) NOT NULL,
	CreatedAt DATETIME2 NOT NULL 
		CONSTRAINT DF_Verification_CreatedAt DEFAULT GETDATE(),
	CreatedBy NVARCHAR(250) NOT NULL
)

COMMIT TRANSACTION CreateLogin 
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
