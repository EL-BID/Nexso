CREATE PROCEDURE [dbo].[dnn_GetModules]

	@PortalID int
	
AS
SELECT	* 
FROM dbo.dnn_vw_Modules
WHERE  PortalId = @PortalID
ORDER BY ModuleId

