CREATE procedure [dbo].[dnn_GetLists]
	
	@PortalID int

AS
	SELECT DISTINCT 
		ListName,
		[Level],
		DefinitionID,
		PortalID,
		SystemList,
		EntryCount,
		ParentID,
		ParentKey,
		Parent,
		ParentList,
		MaxSortOrder
	FROM dbo.dnn_vw_Lists
	WHERE PortalID = @PortalID
	ORDER BY [Level], ListName

