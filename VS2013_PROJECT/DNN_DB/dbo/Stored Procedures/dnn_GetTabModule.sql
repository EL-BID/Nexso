CREATE PROCEDURE [dbo].[dnn_GetTabModule]
    @TabModuleID	int
AS
    SELECT *
	FROM dbo.dnn_vw_TabModules        
    WHERE  TabModuleID = @TabModuleID

