CREATE PROCEDURE [dbo].[dnn_Dashboard_GetDashboardControlByPackageId]  
	@PackageID INT
AS
	
	SELECT *
	  FROM dbo.dnn_Dashboard_Controls
		WHERE PackageID = @PackageID AND PackageID <> -1

