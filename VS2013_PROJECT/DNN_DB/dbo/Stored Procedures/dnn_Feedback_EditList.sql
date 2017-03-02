/* Feedback_EditList */

CREATE PROCEDURE [dbo].[dnn_Feedback_EditList]
	@IsDeleteOperation bit,
	@ListID int,
	@PortalID int, 
	@ListType int, 
	@Name nvarchar(50), 
	@ListValue nvarchar(100),
	@IsActive bit,
    @Portal bit,
    @ModuleID int
AS
  BEGIN
	DECLARE @SortFrom int
	DECLARE @TempListType int

	IF @IsDeleteOperation = 1
	    BEGIN
	        SELECT @SortFrom = [SortOrder],@TempListType = [ListType] from dbo.[dnn_FeedbackList] 
	        WHERE ListID = @ListID

	        DELETE FROM dbo.[dnn_FeedbackList] 
	        WHERE ListID = @ListID

	        --Now check whether we need to resort everything.
	        UPDATE dbo.[dnn_FeedbackList]
	        SET SortOrder = (SortOrder -1) WHERE ListType = @TempListType and SortOrder > @SortFrom
	    END
    ELSE
	    BEGIN
	        UPDATE dbo.[dnn_FeedbackList] 
	        SET
		        PortalID = @PortalID,
		        ListType = @ListType,
		        Name = @Name,
		        ListValue = @ListValue,
		        IsActive = @IsActive,
                Portal = @Portal,
                ModuleID = @ModuleID
	        WHERE ListID = @ListID
	    END
  END
