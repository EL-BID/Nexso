CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessagesBySender]
    @SenderUserID INT,
	@PortalID INT
AS
BEGIN
	SELECT [MessageID], [To], [From], [Subject], [Body], [ConversationID], [ReplyAllAllowed], [SenderUserID], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate] 
	FROM   dbo.[dnn_CoreMessaging_Messages] 
	WHERE  [SenderUserID] = @SenderUserID AND [PortalID] = @PortalID
	AND [NotificationTypeID] IS NULL
END

