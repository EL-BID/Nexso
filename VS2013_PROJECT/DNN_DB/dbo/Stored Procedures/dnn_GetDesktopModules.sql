CREATE PROCEDURE [dbo].[dnn_GetDesktopModules]
AS
	SELECT *
	FROM  dbo.dnn_vw_DesktopModules
	ORDER BY FriendlyName

