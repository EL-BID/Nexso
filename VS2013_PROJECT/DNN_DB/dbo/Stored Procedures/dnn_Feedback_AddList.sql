/* Feedback_AddList */

CREATE PROCEDURE [dbo].[dnn_Feedback_AddList]
	@PortalID int, 
	@ListType int, 
	@Name nvarchar(50), 
	@ListValue nvarchar(100),
	@IsActive bit,
    @Portal bit,
    @ModuleID int
AS

BEGIN
     DECLARE @SortOrder int
     DECLARE @Count int

     SET @SortOrder = IsNull((SELECT MAX ([SortOrder]) From dbo.[dnn_FeedbackList]           
     WHERE [PortalID] = @PortalID and  [ListType] = @ListType), -1) + 1

     SELECT @Count =  COUNT(*) from dbo.[dnn_FeedbackList] where [PortalID] = @PortalID         
        and [Name] = @Name and [ListType] = @ListType

	IF @Count = 0 
	    BEGIN
	        INSERT INTO dbo.[dnn_FeedbackList]  (
		        PortalID,
		        ListType,
		        IsActive,
		        [Name],
		        ListValue,
		        SortOrder,
                Portal,
                ModuleID
	        ) 
	        VALUES (
		        @PortalID,
		        @ListType,
		        @IsActive,
		        @Name,
		        @ListValue,
		        @SortOrder,
                @Portal,
                @ModuleID
	         )
	       SELECT SCOPE_IDENTITY()
	    END
END
