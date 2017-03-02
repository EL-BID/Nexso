CREATE PROCEDURE [dbo].[dnn_Dashboard_DeleteControl]  

	@DashboardControlID int

AS
	DELETE dbo.dnn_Dashboard_Controls 
	WHERE DashboardControlID = @DashboardControlID

