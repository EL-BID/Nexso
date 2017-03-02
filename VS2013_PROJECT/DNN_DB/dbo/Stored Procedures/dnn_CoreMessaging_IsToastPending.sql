CREATE PROCEDURE [dbo].[dnn_CoreMessaging_IsToastPending]	
    @NotificationId int
AS
BEGIN
    SELECT Sendtoast 
    FROM dbo.[dnn_CoreMessaging_MessageRecipients]
    WHERE MessageId = @NotificationId
END

