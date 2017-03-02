CREATE PROCEDURE [dbo].[dnn_Feedback_GetLastSubmissionDateForUserIP]
    	@PortalID int,
	@RemoteAddr nvarchar(50)
AS
	SELECT TOP 1
       		CreatedOnDate
	FROM   dbo.dnn_Feedback
	WHERE  ((PortalID = @PortalID) AND (SenderRemoteAddr = @RemoteAddr))
	ORDER BY CreatedOnDate DESC
