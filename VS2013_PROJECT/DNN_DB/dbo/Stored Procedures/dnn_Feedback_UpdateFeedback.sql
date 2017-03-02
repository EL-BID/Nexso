/***  Feedback_UpdateFeedback  ***/

CREATE PROCEDURE [dbo].[dnn_Feedback_UpdateFeedback]
	@ModuleID int,
	@FeedbackID int, 
	@Subject nvarchar(200),
	@Message nvarchar(1000),
	@UserId int
AS

UPDATE dbo.[dnn_Feedback]
SET
	[Subject] = @Subject,
	[Message] = @Message, 
	LastModifiedByUserID = @UserId,
	LastModifiedOnDate = getutcdate()
	    
WHERE FeedbackID = @FeedbackID and ((@ModuleID = -1) or (ModuleID = @ModuleID))
