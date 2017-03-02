CREATE PROCEDURE [dbo].[dnn_GetContentItemsByModuleId] 
	@ModuleId int
AS
	SELECT * FROM dbo.dnn_ContentItems WHERE ModuleID = @ModuleId

