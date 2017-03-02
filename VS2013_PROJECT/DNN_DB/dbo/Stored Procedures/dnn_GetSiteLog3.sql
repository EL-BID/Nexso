CREATE PROCEDURE [dbo].[dnn_GetSiteLog3]
	@PortalId 	 Int,			-- not Null
	@PortalAlias nVarChar(50),  -- ignored
	@StartDate   DateTime,      -- Not Null
	@EndDate 	 DateTime		-- Not Null
AS
BEGIN
	SELECT U.DisplayName AS 'Name',
           count(*)      AS 'Requests',
           Max(DateTime) AS 'LastRequest'
	FROM       dbo.dnn_SiteLog L
	INNER JOIN dbo.dnn_Users   U on L.UserId = U.UserId
	WHERE L.PortalId = @PortalId
	  AND L.DateTime BETWEEN @StartDate AND @EndDate
	GROUP BY U.DisplayName
	ORDER BY Requests DESC
END

