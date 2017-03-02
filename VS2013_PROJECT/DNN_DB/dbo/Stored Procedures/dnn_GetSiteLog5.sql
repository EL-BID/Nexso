CREATE PROCEDURE [dbo].[dnn_GetSiteLog5]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
BEGIN
	SELECT dbo.[dnn_BrowserFromUserAgent](L.UserAgent) AS 'UserAgent',
		   Count(*)      AS 'Requests',
		   Max(DateTime) AS 'LastRequest'
	FROM dbo.dnn_SiteLog L
	WHERE PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	GROUP BY dbo.[dnn_BrowserFromUserAgent](L.UserAgent)
	ORDER BY Requests DESC
END

