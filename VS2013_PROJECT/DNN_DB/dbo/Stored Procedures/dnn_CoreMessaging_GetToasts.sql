CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetToasts]	
    @UserId int,
    @PortalId int
AS
BEGIN	
    SELECT DISTINCT m.*
    FROM dbo.dnn_CoreMessaging_MessageRecipients mr 
        INNER JOIN dbo.dnn_CoreMessaging_Messages m
    ON mr.MessageID = m.MessageID	
    WHERE mr.UserID = @UserID
    AND   m.PortalID = @PortalID
    AND   mr.SendToast = 1
END

