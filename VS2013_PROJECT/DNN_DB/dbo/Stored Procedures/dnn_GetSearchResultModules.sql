CREATE procedure [dbo].[dnn_GetSearchResultModules]

@PortalID int

AS

SELECT     
		TM.TabID, 
		T.TabName  AS SearchTabName
FROM	dbo.dnn_Modules M
INNER JOIN	dbo.dnn_ModuleDefinitions MD ON MD.ModuleDefID = M.ModuleDefID 
INNER JOIN	dbo.dnn_TabModules TM ON TM.ModuleID = M.ModuleID 
INNER JOIN	dbo.dnn_Tabs T ON T.TabID = TM.TabID
WHERE	MD.FriendlyName = N'Search Results'
	AND T.PortalID = @PortalID
	AND T.IsDeleted = 0

