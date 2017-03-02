CREATE PROCEDURE [dbo].[dnn_DeleteDesktopModule]
	@DesktopModuleId int
AS
-- delete custom permissions
DELETE FROM dbo.dnn_Permission
WHERE moduledefid in 
	(SELECT moduledefid 
	FROM dbo.dnn_ModuleDefinitions
	WHERE desktopmoduleid = @DesktopModuleId)
	
DELETE FROM dbo.dnn_DesktopModules 
WHERE DesktopModuleId = @DesktopModuleId

