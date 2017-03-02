CREATE PROCEDURE [dbo].[dnn_GetSiteLog8]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS	
BEGIN
	SELECT 
		DatePart(month, DateTime) 		  AS 'Month',
		Count(*)                          AS 'Views',
		Count(Distinct L.UserHostAddress) AS 'Visitors',
		Count(Distinct L.UserId) 		  AS 'Users'
	FROM dbo.dnn_SiteLog L
	WHERE PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	GROUP BY datepart(Month, L.DateTime)
	ORDER BY Month
END

