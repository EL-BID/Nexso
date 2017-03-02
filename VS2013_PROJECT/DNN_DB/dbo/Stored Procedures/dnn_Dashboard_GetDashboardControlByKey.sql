CREATE PROCEDURE [dbo].[dnn_Dashboard_GetDashboardControlByKey]  
	@DashboardControlKey nvarchar(50)
AS
	
	SELECT *
	  FROM dbo.dnn_Dashboard_Controls
		WHERE DashboardControlKey = @DashboardControlKey

