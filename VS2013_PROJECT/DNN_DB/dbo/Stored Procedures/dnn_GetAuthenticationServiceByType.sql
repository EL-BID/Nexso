CREATE PROCEDURE [dbo].[dnn_GetAuthenticationServiceByType]

	@AuthenticationType nvarchar(100)

AS
	SELECT *
		FROM  dbo.dnn_Authentication
		WHERE AuthenticationType = @AuthenticationType

