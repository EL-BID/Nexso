CREATE procedure [dbo].[dnn_Dashboard_GetDbInfo]
AS
	
	SELECT
		ServerProperty('ProductVersion') AS ProductVersion, 
		ServerProperty('ProductLevel') AS ServicePack, 
		ServerProperty('Edition') AS ProductEdition, 
		@@VERSION AS SoftwarePlatform

