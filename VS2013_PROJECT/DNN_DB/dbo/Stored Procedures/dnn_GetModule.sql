CREATE PROCEDURE [dbo].[dnn_GetModule]

	@ModuleId int,
	@TabId    int
	
AS
SELECT	* 
FROM dbo.dnn_vw_Modules
WHERE   ModuleId = @ModuleId
AND     (TabId = @TabId or @TabId is null)

