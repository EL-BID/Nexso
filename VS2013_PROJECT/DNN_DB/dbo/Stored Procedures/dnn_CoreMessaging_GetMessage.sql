CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessage]
    @MessageID INT
AS 
	SELECT [MessageID], [PortalId], [NotificationTypeID], [To], [From], [Subject], [Body], [ConversationID], [ReplyAllAllowed], [SenderUserID], [CreatedByUserID], [CreatedOnDate], [LastModifiedByUserID], [LastModifiedOnDate] 
	FROM   dbo.[dnn_CoreMessaging_Messages] 
	WHERE  [MessageID] = @MessageID

