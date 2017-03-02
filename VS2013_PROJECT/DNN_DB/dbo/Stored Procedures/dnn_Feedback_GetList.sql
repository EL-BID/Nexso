/* Feedback_GetList */

CREATE PROCEDURE [dbo].[dnn_Feedback_GetList]
	@SingleRowOperation bit,
	@PortalID int, 
	@ListID int,
	@ListType int,
	@ActiveOnly bit,
    @ModuleID int,
    @AllList bit
AS
    IF @SingleRowOperation = 0 
	    BEGIN
	        IF @ActiveOnly = 1
  		        BEGIN
		            SELECT *, 0 as CategoryCount FROM dbo.[dnn_FeedbackList] 
		             WHERE ([PortalID] = @PortalID and [ListType] = @ListType and IsActive = 1) and
                           (Portal = 1 or (Portal = 0 and ModuleID = @ModuleID) or @AllList = 1)
                     ORDER BY SortOrder ASC
		        END
	        ELSE
		        BEGIN
		            SELECT *, 0 as CategoryCount FROM dbo.[dnn_FeedbackList] 
		             WHERE [PortalID] = @PortalID and [ListType] = @ListType
                     ORDER BY SortOrder ASC
		        END
	    END
	ELSE
	    BEGIN
		    SELECT *,
                   (Select Count(*) FROM dbo.[dnn_Feedback] WHERE CategoryID = @ListID and ModuleID <> @ModuleID) as CategoryCount
              FROM dbo.[dnn_FeedbackList] 
		     WHERE [PortalID] = @PortalID and ListID = @ListID
	    END
