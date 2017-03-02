/* Feedback_CleanupFeedback */

CREATE PROCEDURE [dbo].[dnn_Feedback_CleanupFeedback]
    	@ModuleID int,
        @Pending bit,
    	@Private bit,
    	@Published bit,
    	@Archived bit,
    	@Spam bit,
    	@DaysBefore int,
    	@MaxEntries int
AS
	DELETE FROM dbo.dnn_Feedback
	WHERE CreatedOnDate < DateAdd(day, - @DaysBefore, getutcdate())
      AND ModuleID = @ModuleID 
	  AND ((@Pending <> 0 and Status = 0) OR
		   (@Private <> 0 and Status = 1) OR	
		   (@Published <> 0 and Status = 2) OR	
		   (@Archived <> 0 and Status = 3) OR	
		   (@Spam <> 0 and Status = 5))
		   
	DECLARE @DeleteCount Int
	IF @Pending <> 0
		BEGIN
			SET @DeleteCount = (SELECT COUNT(FeedbackID) FROM dbo.dnn_Feedback WHERE Status = 0) - @MaxEntries
			IF @DeleteCount > 0 
				BEGIN
					DELETE FROM dbo.dnn_Feedback WHERE FeedbackID in (SELECT TOP (@DeleteCount) FeedbackID FROM dbo.dnn_Feedback WHERE Status = 0 AND ModuleID = @ModuleID Order By CreatedOnDate Asc)
				END
		END 
	IF @Private <> 0
		BEGIN
			SET @DeleteCount = (SELECT COUNT(FeedbackID) FROM dbo.dnn_Feedback WHERE Status = 1) - @MaxEntries
			IF @DeleteCount > 0 
				BEGIN
					DELETE FROM dbo.dnn_Feedback WHERE FeedbackID in (SELECT TOP (@DeleteCount) FeedbackID FROM dbo.dnn_Feedback WHERE Status = 1 AND ModuleID = @ModuleID Order By CreatedOnDate Asc)
				END
		END 
	IF @Published <> 0
		BEGIN
			SET @DeleteCount = (SELECT COUNT(FeedbackID) FROM dbo.dnn_Feedback WHERE Status = 2) - @MaxEntries
			IF @DeleteCount > 0 
				BEGIN
					DELETE FROM dbo.dnn_Feedback WHERE FeedbackID in (SELECT TOP (@DeleteCount) FeedbackID FROM dbo.dnn_Feedback WHERE Status = 2 AND ModuleID = @ModuleID Order By CreatedOnDate Asc)
				END
		END 
	IF @Archived <> 0
		BEGIN
			SET @DeleteCount = (SELECT COUNT(FeedbackID) FROM dbo.dnn_Feedback WHERE Status = 3) - @MaxEntries
			IF @DeleteCount > 0 
				BEGIN
					DELETE FROM dbo.dnn_Feedback WHERE FeedbackID in (SELECT TOP (@DeleteCount) FeedbackID FROM dbo.dnn_Feedback WHERE Status = 3 AND ModuleID = @ModuleID Order By CreatedOnDate Asc)
				END
		END 
	IF @Spam <> 0
		BEGIN
			SET @DeleteCount = (SELECT COUNT(FeedbackID) FROM dbo.dnn_Feedback WHERE Status = 5) - @MaxEntries
			IF @DeleteCount > 0 
				BEGIN
					DELETE FROM dbo.dnn_Feedback WHERE FeedbackID in (SELECT TOP (@DeleteCount) FeedbackID FROM dbo.dnn_Feedback WHERE Status = 5 AND ModuleID = @ModuleID Order By CreatedOnDate Asc)
				END
		END
