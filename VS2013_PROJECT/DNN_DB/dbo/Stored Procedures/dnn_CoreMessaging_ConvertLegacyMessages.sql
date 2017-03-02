CREATE PROCEDURE [dbo].[dnn_CoreMessaging_ConvertLegacyMessages]    
	@PageIndex       int,
	@PageSize        int
AS

-- Set the page bounds
DECLARE @PageLowerBound INT, @PageUpperBound INT;

SET @PageLowerBound =  (@PageIndex * @PageSize) + 1
SET @PageUpperBound =  (@PageIndex * @PageSize) + @PageSize

	DECLARE @MessageID bigint	
	DECLARE @PortalID INT
	DECLARE @FromUserName nvarchar(50)
	DECLARE @FromUserID INT
	DECLARE @ToUserName nvarchar(50)
	DECLARE @ToUserID int
	DECLARE @Status tinyint
	DECLARE @Subject nvarchar(max)
	DECLARE @Body nvarchar(max)
	DECLARE @Date datetime
	DECLARE @EmailSent bit
	DECLARE @EmailSentDate datetime
	DECLARE @EmailSchedulerInstance UNIQUEIDENTIFIER
	DECLARE @RowNumber INT
	
	DECLARE @NewMessageID int	
	DECLARE @Counter int		

	DECLARE MessageList cursor FAST_FORWARD for

	WITH messageItems  AS
	(
		SELECT  [MessageID], [PortalID],[FromUserName],[FromUserID], [ToUserName], [ToUserID], [Status], [Subject], [Body], [Date], [EmailSent], [EmailSentDate], [EmailSchedulerInstance] 
				,ROW_NUMBER() OVER(ORDER BY MessageID ASC) AS RowNumber
		FROM	dbo.[dnn_Messaging_Messages]
	)
	
	SELECT * from messageItems where RowNumber BETWEEN @PageLowerBound AND @PageUpperBound
	ORDER BY RowNumber ASC
	OPEN MessageList
	FETCH NEXT FROM MessageList 
		INTO @MessageID, @PortalID, @FromUserName, @FromUserID, @ToUserName, @ToUserID, @Status, @Subject, @Body, @Date, @EmailSent, @EmailSentDate, @EmailSchedulerInstance, @RowNumber 

	WHILE @@FETCH_STATUS = 0
	BEGIN
			--Create SocialMessage Record
            INSERT dbo.[dnn_CoreMessaging_Messages](                    
  					[PortalID],
					[To],
					[From],					
					[Subject],
					[Body],
					[ConversationID],
					[ReplyAllAllowed],
					[SenderUserID],
                    [CreatedByUserID],
                    [CreatedOnDate],
                    [LastModifiedByUserID],
                    [LastModifiedOnDate]			        
                    )
            VALUES  (       
					@PortalID,
					@ToUserName,
					@FromUserName,
					@Subject,
					@Body,
					NULL,
					1, --ReplyAllAllowed,
					@FromUserID,
                    @FromUserID , -- CreatedBy - int
					dateadd(second, (-1 * datediff(second, getutcdate(), getdate())), @Date), -- CreatedOn - utc datetime
                    @FromUserID , -- LastModifiedBy - int
                    GETDATE() -- LastModifiedOn - datetime			        
                    )
            -- update conversation id                       
            SELECT  @NewMessageID = SCOPE_IDENTITY()
			UPDATE  dbo.[dnn_CoreMessaging_Messages] SET [ConversationID] = @NewMessageID WHERE [MessageID] = @NewMessageID 															
			
			--Create SocialRecipient Record for recipient and sender. 2 records total
			Set @Counter = 0 
			
			--No need to create two records if message sent to self	
			IF @ToUserID = @FromUserID BEGIN Set @Counter = 1 END
					
			WHILE @Counter < 2
			BEGIN
				SET @Counter = @Counter + 1
			
				INSERT dbo.[dnn_CoreMessaging_MessageRecipients](
						[MessageID],
						[UserID],
						[Read],
						[Archived],
						[CreatedByUserID],
						[CreatedOnDate],
						[LastModifiedByUserID],
						[LastModifiedOnDate],
						[EmailSent],
						[EmailSentDate],
						[EmailSchedulerInstance]                    
						)
				VALUES  (
						@NewMessageID,
						CASE @Counter
							WHEN 1 THEN @ToUserID 
							ELSE @FromUserID 
						END,												
						CASE @Status
							WHEN 1 THEN 0 --Status 1 means Unread, 2 means Read, 3 means Deleted
							ELSE 1
						END,
						CASE @Status
							WHEN 3 THEN 1 --Status 1 means Unread, 2 means Read, 3 means Deleted
							ELSE 0
						END,
						@FromUserID , -- CreatedBy - int
						@Date , -- CreatedOn - datetime
						@FromUserID , -- LastModifiedBy - int
						@Date, -- LastModifiedOn - datetime
						@EmailSent,
						@EmailSentDate,
						@EmailSchedulerInstance
						)			
			END
		
		--Delete the Legacy record
		DELETE FROM dbo.[dnn_Messaging_Messages] WHERE MessageID = @MessageID
		
		FETCH NEXT FROM MessageList 
			INTO @MessageID,@PortalID, @FromUserName, @FromUserID, @ToUserName, @ToUserID, @Status, @Subject, @Body, @Date, @EmailSent, @EmailSentDate, @EmailSchedulerInstance, @RowNumber 
	END
	CLOSE MessageList
	DEALLOCATE MessageList

