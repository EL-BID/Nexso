CREATE PROCEDURE [dbo].[dnn_Dashboard_GetInstalledModules]
AS
	SELECT		
		DesktopModuleID, 
		ModuleName,
		FriendlyName,
		Version,
		(SELECT     COUNT(*) AS Instances
			FROM          dbo.dnn_DesktopModules 
				INNER JOIN dbo.dnn_ModuleDefinitions ON dbo.dnn_DesktopModules.DesktopModuleID = dbo.dnn_ModuleDefinitions.DesktopModuleID 
				INNER JOIN dbo.dnn_Modules ON dbo.dnn_ModuleDefinitions.ModuleDefID = dbo.dnn_Modules.ModuleDefID
			WHERE      (dbo.dnn_DesktopModules.DesktopModuleID = DM.DesktopModuleID)) AS Instances
	FROM dbo.dnn_DesktopModules AS DM
	WHERE (IsAdmin = 0)
	ORDER BY [FriendlyName] ASC

