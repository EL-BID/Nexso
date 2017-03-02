/***  Feedback_UpdateStatus  ***/

CREATE PROCEDURE [dbo].[dnn_Feedback_UpdateStatus]
	@ModuleID int,
	@FeedbackID int, 
	@Status int,
	@UserId int
AS

DECLARE @PublishedOnDate datetime
DECLARE @ApprovedBy int

IF @Status = 4 
	DELETE dbo.[dnn_Feedback] WHERE FeedbackID = @FeedbackID and ((@ModuleID = -1) or (ModuleID = @ModuleID))
ELSE
	IF @Status=2
	  BEGIN
		SET @PublishedOnDate = getutcdate()
		SET @ApprovedBy = @UserId
	  END
	ELSE
	  BEGIN
		SET @PublishedOnDate = (SELECT PublishedOnDate FROM dbo.[dnn_Feedback] WHERE FeedbackID=@FeedbackID)
		SET @ApprovedBy = (SELECT ApprovedBy FROM dbo.[dnn_Feedback] WHERE FeedbackID=@FeedbackID)
	  END

	UPDATE dbo.[dnn_Feedback]
	SET
	   Status = @Status,
	   PublishedOnDate = @PublishedOnDate,
	   ApprovedBy = @ApprovedBy,
	   LastModifiedByUserID = @UserId,
	   LastModifiedOnDate = getutcdate()
	   
	WHERE FeedbackID = @FeedbackID and ((@ModuleID = -1) or (ModuleID = @ModuleID))
