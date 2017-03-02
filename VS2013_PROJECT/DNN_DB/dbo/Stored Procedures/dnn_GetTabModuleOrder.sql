CREATE PROCEDURE [dbo].[dnn_GetTabModuleOrder]
	@TabId    int, 			-- Not Null
	@PaneName nvarchar(50)  -- Not Null
AS
BEGIN
	SELECT *
	FROM dnn_TabModules 
	WHERE TabId    = @TabId 
	  AND PaneName = @PaneName
	ORDER BY TabId, PaneName, ModuleOrder -- optimized for index used
END

