CREATE PROCEDURE [dbo].[dnn_Feedback_ChangeListSortOrder]
	@ListID int,
	@ListType int,
	@OldSortNum int,
	@NewSortNum int
AS

	DECLARE @TempListID int
	SELECT @TempListID = ListID FROM dbo.[dnn_FeedbackList]
	WHERE ListType = @ListType and SortOrder = @NewSortNum


	UPDATE dbo.[dnn_FeedbackList] 
	SET SortOrder = @NewSortNum WHERE ListID = @ListID
	
	--now switch the other one.
	UPDATE dbo.[dnn_FeedbackList] 
	SET SortOrder = @OldSortNum WHERE ListID = @TempListID
