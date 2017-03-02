CREATE PROCEDURE [dbo].[dnn_GetPermissions]
AS
	SELECT * FROM dbo.dnn_Permission
	ORDER BY ViewOrder

