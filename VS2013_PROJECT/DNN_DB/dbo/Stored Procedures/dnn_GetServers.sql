CREATE PROCEDURE [dbo].[dnn_GetServers] 
AS
	SELECT *
	FROM dbo.dnn_WebServers
	ORDER BY ServerName, IISAppName

