CREATE PROCEDURE [dbo].[dnn_GetTabCustomAliases] 
(
	 @PortalID		int 
)
AS
	SELECT 
		t.TabId, 
		Coalesce(trp.CultureCode, '') as CultureCode, 
		pa.HttpAlias
	FROM dbo.dnn_Tabs t
		INNER JOIN dbo.dnn_TabUrls trp ON trp.TabId = t.ParentId	
		INNER JOIN dbo.dnn_PortalAlias pa ON trp.PortalAliasId = pa.PortalAliasId
		WHERE trp.PortalAliasUsage = 1 /* child tabs inherit */
		  AND (@portalId = t.PortalId OR @portalId = -1)
		  AND NOT EXISTS (SELECT tr2.TabId 
							FROM dbo.dnn_TabUrls tr2 
							WHERE tr2.TabId = t.TabId 
								AND tr2.CultureCode = trp.CultureCode
							)

