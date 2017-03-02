CREATE PROCEDURE [dbo].[dnn_DeleteAuthentication]
	@AuthenticationID int
AS
	DECLARE @AuthType nvarchar(100)
	SET @AuthType = (SELECT AuthenticationType FROM dbo.dnn_Authentication WHERE AuthenticationID = @AuthenticationID)
	
	-- Delete UserAuthentication rows
	IF (@AuthType Is Not Null)
		BEGIN
			DELETE FROM dbo.dnn_UserAuthentication
				WHERE AuthenticationType = @AuthType
		END

	-- Delete Record
	DELETE 
		FROM   dbo.dnn_Authentication
		WHERE AuthenticationID = @AuthenticationID

