CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CheckReplyHasRecipients]
	@ConversationId Int, -- Not Null
	@UserId 		Int  -- Not Null
AS 
BEGIN
	SELECT COUNT(M.UserID)
	FROM       dbo.dnn_vw_CoreMessaging_Messages AS M
	INNER JOIN dbo.dnn_vw_Users AS U ON M.UserID = U.UserID AND M.PortalID = IsNull(U.PortalID, M.PortalID)
	WHERE (M.MessageID = @ConversationId) 
	  AND (M.UserID   <> @UserId) 
	  AND (U.IsDeleted = 0)
END

