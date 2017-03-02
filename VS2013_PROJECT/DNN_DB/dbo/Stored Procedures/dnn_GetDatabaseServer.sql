CREATE PROCEDURE [dbo].[dnn_GetDatabaseServer]
AS
	SELECT ServerProperty('Edition') AS ProductName,
           ServerProperty('ProductVersion') AS Version

