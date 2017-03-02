CREATE PROCEDURE [dbo].[dnn_GetSiteLog9]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS	
BEGIN
	SELECT 
		T.TabName     AS 'Page',
		Count(*)      AS 'Requests',
		Max(DateTime) AS 'LastRequest'
	FROM       dbo.dnn_SiteLog L
	INNER JOIN dbo.dnn_Tabs    T ON L.TabId = T.TabId
	WHERE L.PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	GROUP BY T.TabName
	ORDER BY Requests DESC
END

