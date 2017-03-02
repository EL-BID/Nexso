CREATE PROCEDURE [dbo].[dnn_Messaging_Save_Message] 
   @PortalID int,
   @FromUserID int,
   @ToUserID int,
   @ToRoleID int,
   @Status int,
   @Subject nvarchar(max),
   @Body nvarchar(max),
   @Date datetime,
   @Conversation uniqueidentifier,
   @ReplyTo bigint,
   @AllowReply bit,
   @SkipPortal bit

AS
	BEGIN
		INSERT INTO dbo.dnn_Messaging_Messages
       ([PortalID]
       ,[FromUserID]
	   ,[FromUserName]
       ,[ToUserID]
       ,[ToRoleID]
	   ,[ToUserName]
       ,[Status]
       ,[Subject]
       ,[Body]
       ,[Date]
       ,[Conversation]
       ,[ReplyTo]
       ,[AllowReply]
       ,[SkipPortal]
		,[EmailSent])
 SELECT
       @PortalID,
       @FromUserID,
	   (SELECT UserName FROM dnn_Users WHERE UserID = @FromUserID) as FromUserName,
       @ToUserID,
       @ToRoleID,
	   (SELECT UserName FROM dnn_Users WHERE UserID = @ToUserID) as ToUserName, 
       @Status,
       @Subject, 
       @Body,
       @Date, 
       @Conversation,
       @ReplyTo,
       @AllowReply, 
       @SkipPortal,
	   '0'
			
		SELECT SCOPE_IDENTITY()						
	END

