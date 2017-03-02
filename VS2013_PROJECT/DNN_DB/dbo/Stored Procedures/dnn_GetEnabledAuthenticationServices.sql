CREATE PROCEDURE [dbo].[dnn_GetEnabledAuthenticationServices]
AS
	SELECT *
		FROM   dbo.dnn_Authentication
		WHERE  IsEnabled = 1

