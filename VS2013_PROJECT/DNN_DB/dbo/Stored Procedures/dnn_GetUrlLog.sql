CREATE PROCEDURE [dbo].[dnn_GetUrlLog]
	@URLTrackingID Int,
	@StartDate DateTime,
	@EndDate DateTime
AS
	BEGIN
		SELECT 
			L.*,
			dbo.[dnn_UserDisplayname](L.UserId) AS 'FullName'
		FROM dbo.dnn_UrlLog L
			INNER JOIN dbo. dnn_UrlTracking T ON L.UrlTrackingId = T.UrlTrackingId
		WHERE L.UrlTrackingID = @UrlTrackingID
			AND ((ClickDate >= @StartDate) OR @StartDate Is Null)
			AND ((ClickDate <= @EndDate ) OR @EndDate Is Null)
		ORDER BY ClickDate
	END

