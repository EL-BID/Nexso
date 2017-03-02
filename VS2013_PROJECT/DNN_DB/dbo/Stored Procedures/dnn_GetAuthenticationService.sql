CREATE PROCEDURE [dbo].[dnn_GetAuthenticationService]

	@AuthenticationID int

AS
	SELECT *
		FROM   dbo.dnn_Authentication
		WHERE AuthenticationID = @AuthenticationID

