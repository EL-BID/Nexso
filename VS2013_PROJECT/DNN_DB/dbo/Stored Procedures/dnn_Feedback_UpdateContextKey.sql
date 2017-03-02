/***  Feedback_UpdateContextKey  ***/

CREATE PROCEDURE [dbo].[dnn_Feedback_UpdateContextKey]
	@ModuleID int,
	@FeedbackID int, 
	@ContextKey nvarchar(200),
	@UserId int
AS

UPDATE dbo.[dnn_Feedback]
SET
	ContextKey = @ContextKey, 
	LastModifiedByUserID = @UserId,
	LastModifiedOnDate = getutcdate()
	    
WHERE FeedbackID = @FeedbackID and ((@ModuleID = -1) or (ModuleID = @ModuleID))
