CREATE PROCEDURE [dbo].[dnn_GetTabModules]
	@TabId int -- not null!
AS
BEGIN
	SELECT	* 
	FROM dbo.dnn_vw_TabModules
	WHERE  TabId = @TabId
	ORDER BY TabId, PaneName, ModuleOrder -- optimized for index used
END

