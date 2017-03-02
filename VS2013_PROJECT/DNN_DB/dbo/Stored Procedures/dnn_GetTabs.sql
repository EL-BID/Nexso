CREATE PROCEDURE [dbo].[dnn_GetTabs]
	@PortalID Int  -- Null|-1 for host pages
AS
	SELECT *
	FROM   dbo.[dnn_vw_Tabs]
	WHERE  IsNull(PortalId, -1) = IsNull(@PortalID, -1)
	ORDER BY PortalId, [Level], ParentID, TabOrder -- PortalId added for query optimization

