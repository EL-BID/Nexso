CREATE PROCEDURE [dbo].[dnn_GetSearchModules]

@PortalID int

AS
	SELECT *
	FROM dbo.dnn_vw_Modules M
		INNER JOIN dbo.dnn_Tabs T ON T.TabId = M.TabId
	WHERE  M.IsDeleted = 0  
		AND T.IsDeleted = 0  
		AND M.IsAdmin = 0
		AND (M.SupportedFeatures & 2 = 2)
		AND (T.EndDate > GETDATE() or T.EndDate IS NULL) 
		AND (T.StartDate <= GETDATE() or T.StartDate IS NULL) 
		AND (M.StartDate <= GETDATE() or M.StartDate IS NULL) 
		AND (M.EndDate > GETDATE() or M.EndDate IS NULL) 
		AND (NOT (M.BusinessControllerClass IS NULL))
		AND (T.PortalID = @PortalID OR (T.PortalID IS NULL AND @PortalID Is NULL))
	ORDER BY ModuleOrder

