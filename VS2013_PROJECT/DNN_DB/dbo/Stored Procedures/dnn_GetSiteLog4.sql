CREATE PROCEDURE [dbo].[dnn_GetSiteLog4]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- Portal Alias to be eliminated FROM Referrer
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
BEGIN
	SELECT Referrer,
	Count(*)      AS 'Requests',
	Max(DateTime) AS 'LastRequest'
	FROM dbo.dnn_SiteLog L
	WHERE L.PortalId = @PortalID
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	  AND L.Referrer IS Not Null
	  AND L.Referrer Not Like '%' + @PortalAlias + '%'
	GROUP BY Referrer
	ORDER BY Requests DESC
END

