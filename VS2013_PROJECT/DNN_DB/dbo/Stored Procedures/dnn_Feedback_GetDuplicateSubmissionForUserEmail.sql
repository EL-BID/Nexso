/* Feedback_GetDuplicateSubmissionForUserEmail */

CREATE PROCEDURE [dbo].[dnn_Feedback_GetDuplicateSubmissionForUserEmail]
    	@PortalID int,
	    @Email nvarchar(256),
        @Message nvarchar(1000)
AS
	SELECT TOP 1
       		CreatedOnDate
	FROM   dbo.dnn_Feedback
	WHERE  ((PortalID = @PortalID) AND (SenderEmail=@Email) and (Message=@Message))
	ORDER BY CreatedOnDate DESC
