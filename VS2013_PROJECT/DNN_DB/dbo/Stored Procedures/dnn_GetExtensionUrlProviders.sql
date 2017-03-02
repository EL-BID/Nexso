CREATE PROCEDURE [dbo].[dnn_GetExtensionUrlProviders] 
	@PortalID	int 
AS
	SELECT 
		p.*, 
		pc.PortalID
	FROM  dbo.dnn_ExtensionUrlProviderConfiguration pc 
		RIGHT OUTER JOIN dbo.dnn_ExtensionUrlProviders p 
			ON pc.ExtensionUrlProviderID = p.ExtensionUrlProviderID
	WHERE pc.PortalID = @PortalID OR pc.PortalID IS Null

	SELECT ExtensionUrlProviderID, 
			PortalID, 
			SettingName, 
			SettingValue
	FROM dbo.dnn_ExtensionUrlProviderSetting
	WHERE PortalID = PortalID

	SELECT DISTINCT 
			P.ExtensionUrlProviderID,
			TM.TabID
		FROM dbo.dnn_DesktopModules DM
			INNER JOIN dbo.dnn_ModuleDefinitions MD ON DM.DesktopModuleID = MD.DesktopModuleID 
			INNER JOIN dbo.dnn_Modules M ON MD.ModuleDefID = M.ModuleDefID 
			INNER JOIN dbo.dnn_TabModules TM ON M.ModuleID = TM.ModuleID 
			INNER JOIN dbo.dnn_vw_ExtensionUrlProviders P ON DM.DesktopModuleID = P.DesktopModuleId
		WHERE     (P.PortalID = @PortalID) OR (P.PortalID IS NULL)
		  
		UNION
			SELECT  
				P.ExtensionUrlProviderID,
				PT.TabId
			FROM    dbo.dnn_ExtensionUrlProviderTab PT
				INNER JOIN dbo.dnn_ExtensionUrlProviders P ON P.ExtensionUrlProviderID = PT.ExtensionUrlProviderID
			WHERE   (PT.IsActive = 1)

