CREATE PROCEDURE [dbo].[dnn_GetAuthenticationServiceByPackageID]

	@PackageID int

AS
	SELECT *
		FROM  dbo.dnn_Authentication
		WHERE PackageID = @PackageID

