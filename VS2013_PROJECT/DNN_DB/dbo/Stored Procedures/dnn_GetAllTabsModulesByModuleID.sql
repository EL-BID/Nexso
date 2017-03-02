CREATE PROCEDURE [dbo].[dnn_GetAllTabsModulesByModuleID]
    @ModuleID	int
AS
	SELECT	* 
	FROM dbo.dnn_vw_Modules
	WHERE  ModuleID = @ModuleID

