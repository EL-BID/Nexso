CREATE PROCEDURE [dbo].[dnn_Feedback_GetLastSubmissionDateForUserEmail]
    	@PortalID int,
	@Email nvarchar(256)
AS
	SELECT TOP 1
       		CreatedOnDate
	FROM   dbo.dnn_Feedback
	WHERE  ((PortalID = @PortalID) AND (SenderEmail=@Email))
	ORDER BY CreatedOnDate DESC
