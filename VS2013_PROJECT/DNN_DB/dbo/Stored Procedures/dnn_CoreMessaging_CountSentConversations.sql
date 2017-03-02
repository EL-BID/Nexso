CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CountSentConversations]
	@UserID INT,
	@PortalID INT
AS
BEGIN
	SELECT COUNT(DISTINCT ConversationID) AS TotalRecords
	    FROM dbo.[dnn_CoreMessaging_Messages] m
        INNER JOIN dbo.[dnn_CoreMessaging_MessageRecipients] mr ON mr.MessageID = m.MessageID AND mr.UserID = m.SenderUserID --make sure sender haven't delete the message.
	    WHERE SenderUserID = @UserID
	        AND NotificationTypeID IS NULL AND PortalID = @PortalID
END

