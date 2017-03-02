CREATE procedure [dbo].[dnn_GetAllTabsModules]
	@PortalID int,
	@AllTabs bit
AS
	SELECT	* 
	FROM dbo.dnn_vw_Modules M
	WHERE  M.PortalID = @PortalID 
		AND M.IsDeleted = 0
		AND M.AllTabs = @AllTabs
		AND M.TabModuleID =(SELECT min(TabModuleID) 
			FROM dbo.dnn_TabModules
			WHERE ModuleID = M.ModuleID)
	ORDER BY M.ModuleId

