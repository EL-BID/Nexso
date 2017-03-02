CREATE PROCEDURE [dbo].[dnn_GetCustomAliasesForTabs] 
AS
	SELECT HttpAlias
	FROM  dbo.[dnn_PortalAlias] pa 
	WHERE PortalAliasId IN (SELECT PortalAliasId FROM dbo.[dnn_TabUrls])
	ORDER BY HttpAlias

