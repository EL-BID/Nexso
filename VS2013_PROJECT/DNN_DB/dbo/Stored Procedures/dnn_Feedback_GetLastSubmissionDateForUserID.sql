CREATE PROCEDURE [dbo].[dnn_Feedback_GetLastSubmissionDateForUserID]
    	@PortalID int,
	@UserId int
AS
	SELECT TOP 1
       		CreatedOnDate
	FROM   dbo.dnn_Feedback
	WHERE  ((PortalID = @PortalID) AND (CreatedByUserID = @UserId))
	ORDER BY CreatedOnDate DESC
