CREATE PROCEDURE [dbo].[dnn_GetSiteLog2]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- Portal Alias to be eliminated FROM Referrer
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
	BEGIN
		SELECT L.DateTime, 
		U.DisplayName AS 'Name',
		dbo.[dnn_AdjustedReferrer](L.Referrer, @PortalAlias) AS 'Referrer', 
		dbo.[dnn_BrowserFromUserAgent](L.UserAgent) AS 'UserAgent',
		L.UserHostAddress,
		T.TabName
		FROM      dbo.dnn_SiteLog L
		LEFT JOIN dbo.dnn_Users   U ON L.UserId = U.UserId 
		LEFT JOIN dbo.dnn_Tabs    T ON L.TabId  = T.TabId 
		WHERE L.PortalId = @PortalId
		  AND L.DateTime BETWEEN @StartDate AND @EndDate
		ORDER BY L.DateTime DESC
	END

