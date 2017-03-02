CREATE PROCEDURE [dbo].[dnn_Messaging_UpdateMessage] 
   @MessageID bigint,
   @ToUserID int,
   @ToRoleID int,
   @Status int,
   @Subject nvarchar(max),
   @Body nvarchar(max),
   @Date datetime,
   @ReplyTo bigint,
   @AllowReply bit,
   @SkipPortal bit
AS
	UPDATE dbo.dnn_Messaging_Messages
	SET ToUserID=@ToUserID, 
		ToRoleID=@ToRoleID, 
		Status=@Status, 
		Subject=@Subject, 
		Body=@Body, 
		Date= @Date,
		ReplyTo= @ReplyTo,
		AllowReply = @AllowReply,
		SkipPortal = @SkipPortal
	WHERE MessageID=@MessageID

