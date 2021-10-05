USE GigiPhotographyDevelopment
GO 

CREATE OR ALTER TRIGGER TR_AuditLog_InsteadOf_Insert_or_Delete_or_Update
ON 
	dbo.AuditLog INSTEAD OF DELETE, UPDATE
AS
BEGIN
	SELECT 'Rows cannot be Altered or Deleted on the AuditLog Table.' AS Exception
END