CREATE PROCEDURE [dbo].[dnn_CoreMessaging_MarkReadyForToast]	
    @MessageId int,
    @UserId int
AS
BEGIN	
    UPDATE dbo.[dnn_CoreMessaging_MessageRecipients]
    SET Sendtoast = 1,
    [LastModifiedOnDate] = GETDATE()
    WHERE MessageId = @MessageId
    AND UserId = @UserId
END

