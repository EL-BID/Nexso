-- optimized
CREATE VIEW [dbo].[dnn_vw_Lists]
AS
	SELECT  L.EntryID, 
		L.ListName, 
		L.[Value], 
		L.Text, 
		L.[Level], 
		L.SortOrder, 
		L.DefinitionID, 
		L.ParentID, 
		L.Description, 
		L.PortalID, 
		L.SystemList, 
		dbo.[dnn_GetListParentKey](L.ParentID, L.ListName, N'ParentKey',  0) AS ParentKey, 
		dbo.[dnn_GetListParentKey](L.ParentID, L.ListName, N'Parent',     0) AS Parent, 
		dbo.[dnn_GetListParentKey](L.ParentID, L.ListName, N'ParentList', 0) AS ParentList,
		S.MaxSortOrder,
		S.EntryCount,
		CASE WHEN EXISTS (SELECT 1 FROM dbo.[dnn_Lists] WHERE (ParentID = L.EntryID)) THEN 1 ELSE 0 END AS HasChildren, 
		L.CreatedByUserID, 
		L.CreatedOnDate, 
		L.LastModifiedByUserID, 
		L.LastModifiedOnDate
	FROM dbo.[dnn_Lists] AS L
	LEFT JOIN (SELECT ListName, ParentID, Max(SortOrder) AS MaxSortOrder, Count(1) AS EntryCount 
			   FROM dbo.[dnn_Lists] GROUP BY ListName, ParentID) S 		ON L.ParentID = S.ParentId AND L.ListName = S.ListName

