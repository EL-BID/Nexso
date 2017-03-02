CREATE PROCEDURE [dbo].[dnn_GetSearchSettings]

	@ModuleID	int

AS
	SELECT     	settings.SettingName, 
				settings.SettingValue
	FROM	dbo.dnn_Modules m 
		INNER JOIN dbo.dnn_Portals p ON m.PortalID = p.PortalID 
		INNER JOIN dbo.dnn_PortalSettings settings ON p.PortalID = settings.PortalID
	WHERE   m.ModuleID = @ModuleID
		AND settings.SettingName LIKE 'Search%'

