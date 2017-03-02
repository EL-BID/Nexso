CREATE PROCEDURE [dbo].[dnn_GetSiteLog12]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
BEGIN
	SELECT AffiliateId,
		Count(*) 		AS 'Requests',
		Max(DateTime) 	AS 'LastReferral'
	FROM dbo.dnn_SiteLog L
	WHERE L.PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	  AND AffiliateId Is NOT Null
	GROUP BY AffiliateId
	ORDER BY Requests DESC
END

