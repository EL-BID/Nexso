CREATE PROCEDURE [dbo].[dnn_GetTabUrls] 
(
	 @PortalId		int 
)
AS
	SELECT 
		tu.TabId,	
		tu.SeqNum,	
		tu.Url,	
		tu.QueryString,
		tu.HttpStatus,	
		tu.CultureCode,
		tu.IsSystem,
		case when parentTu.PortalAliasUsage = 1 /* parent is set to 'child pages inherit' so get parent portal alias id */
			then 
				case when Coalesce(tu.PortalAliasId, 0) < 1 /* if this page has no specific alias id, then use parent*/
					then parentTu.PortalAliasId 
					else tu.PortalAliasId 
				END /* otherwise, use this page alias id */
			else tu.PortalALiasId 
		END as PortalAliasId,

		case when Coalesce(tu.PortalAliasUsage,0) = 0 and coalesce(tu.PortalALiasId,0) < 1 /* default value and no specific alias */
			then /* check for inheritance from parent */
				case when Coalesce(parentTu.PortalALiasUsage,0) = 1 and Coalesce(parentTu.PortalAliasId, 0) > 0 /* parent specifies an alias */
					then 3 /* inherited from parent */
					else 0 
				END /* default value */
			when Coalesce(tu.PortalAliasId,0) > 0 /*specific alias for this tab */
			then 
				case when coalesce(tu.PortalALiasUsage,0) < 1 
					then 1 /* if not set, default to 'child pages inherit'*/
					else tu.PortalAliasUsage 
				END
			else 
				0 /* default - fall through value */
		END as PortalAliasUsage 
	FROM dbo.dnn_TabUrls tu
		INNER JOIN dbo.dnn_Tabs t on t.TabId = tu.TabId
		LEFT JOIN dbo.dnn_TabUrls parentTu on t.ParentId = parentTu.TabId
			AND parentTu.CultureCode = tu.CultureCode
			and parentTu.PortalAliasUsage > 0	   
	WHERE (@portalId = PortalId OR @portalId = -1)
	ORDER BY PortalId, TabOrder, tu.SeqNum

