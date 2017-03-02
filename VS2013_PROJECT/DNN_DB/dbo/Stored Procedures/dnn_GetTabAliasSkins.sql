CREATE PROCEDURE [dbo].[dnn_GetTabAliasSkins] 
(
	 @PortalID		int 
)
AS
	SELECT 
		t.TabId, 
		pa.PortalAliasId, 
		pa.HttpAlias, 
		t.SkinSrc, 
		t.CreatedByUserId, 
		t.CreatedOnDate, 
		t.LastModifiedByUserId, 
		t.LastModifiedOnDate
	FROM dbo.dnn_TabAliasSkins t
		INNER JOIN dbo.dnn_PortalAlias pa ON t.PortalAliasId = pa.PortalAliasId
	WHERE pa.PortalID = @PortalID OR @PortalID = -1

