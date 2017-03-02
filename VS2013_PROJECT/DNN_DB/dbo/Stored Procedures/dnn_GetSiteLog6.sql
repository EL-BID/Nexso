CREATE PROCEDURE [dbo].[dnn_GetSiteLog6]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
BEGIN
	SELECT
		DatePart(Hour, DateTime)          AS 'Hour',
		Count(*)                          AS 'Views',
		Count(Distinct L.UserHostAddress) AS 'Visitors',
		Count(Distinct L.UserId) 		  AS 'Users'
	FROM dbo.dnn_SiteLog L
	WHERE PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	GROUP BY DatePart(Hour, DateTime)
	ORDER BY Hour
END

