CREATE PROCEDURE [dbo].[dnn_GetSiteLog7]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
BEGIN
	SELECT 
		DatePart(weekday, DateTime) 	  AS 'WeekDay',
		Count(*)                          AS 'Views',
		Count(Distinct L.UserHostAddress) AS 'Visitors',
		Count(Distinct L.UserId) 		  AS 'Users'
	FROM dbo.dnn_SiteLog L
	WHERE PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	GROUP BY DatePart(weekday, DateTime)
	ORDER BY WeekDay
END

