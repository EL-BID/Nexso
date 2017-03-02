CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountArchivedConversations]
	@UserID INT,
	@PortalID INT
AS
BEGIN
	SELECT COUNT(DISTINCT M.ConversationID) AS TotalRecords
	    FROM dbo.[dnn_CoreMessaging_Messages] M
	    JOIN dbo.[dnn_CoreMessaging_MessageRecipients] MR ON M.MessageID = MR.MessageID
	    WHERE Archived = 1
	        AND NotificationTypeID IS NULL AND PortalID = @PortalID AND UserID = @UserID
END

