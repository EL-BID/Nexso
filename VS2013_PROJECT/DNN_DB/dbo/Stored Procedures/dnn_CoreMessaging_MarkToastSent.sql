CREATE PROCEDURE [dbo].[dnn_CoreMessaging_MarkToastSent]	
    @MessageId int,
	@UserId INT
AS
BEGIN	
    UPDATE dbo.dnn_CoreMessaging_MessageRecipients
    SET Sendtoast = 0,
    [LastModifiedOnDate] = GETDATE()
    WHERE MessageId = @MessageId
	AND UserId = @UserId
END

