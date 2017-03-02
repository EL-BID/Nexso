CREATE PROCEDURE [dbo].[dnn_GetSiteLog1]
	@PortalID 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
	BEGIN
		SELECT Convert(VarChar, DateTime, 102)   AS 'Date',
			   Count(*) 						 AS 'Views',
			   Count(Distinct L.UserHostAddress) AS 'Visitors',
			   Count(Distinct L.UserId)          AS 'Users'
		FROM dbo.dnn_SiteLog L
		WHERE PortalId = @PortalID
		  AND L.DateTime BETWEEN @StartDate AND @EndDate
		GROUP BY Convert(VarChar, DateTime, 102)
		ORDER BY Date DESC
	END

