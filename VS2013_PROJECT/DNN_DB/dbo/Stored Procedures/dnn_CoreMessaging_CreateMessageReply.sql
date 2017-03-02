CREATE PROCEDURE [dbo].[dnn_CoreMessaging_CreateMessageReply]
    @ConversationID    INT,           -- parent message id
	@PortalID			INT,			--portalID of message
    @Body               nvarchar(max), -- message body
    @SenderUserID       INT,           -- create / update user id
    @From               nvarchar(200), -- message from
	@CreateUpdateUserID INT            -- create / update user id
AS
    DECLARE @ReplyAllAllowed BIT
    DECLARE @NewMessageID INT
    DECLARE @OriginalSenderUserID INT
    DECLARE @OriginalTo nvarchar(2000)
    DECLARE @OriginalSubject nvarchar(400)

	--Was Sender a Recipient in the Original Message.
	SELECT @ReplyAllAllowed = [ReplyAllAllowed],
	       @OriginalSenderUserID = [SenderUserID],
		   @OriginalTo = REPLACE(REPLACE([TO] + ',' + [FROM], ',' + @From, ''), @From + ',', ''),
		   @OriginalSubject = [Subject]
	FROM dbo.dnn_CoreMessaging_Messages m
	INNER JOIN dbo.dnn_CoreMessaging_MessageRecipients mr ON m.MessageID = mr.MessageID
	AND m.MessageID = @ConversationID
	AND mr.UserID = @SenderUserID

	--Reply can only be create if Sender was Recipient of Orginial message
	IF @ReplyAllAllowed IS NULL
	BEGIN
		SELECT -1
		RETURN
	END

	--Create new message
	INSERT dbo.dnn_CoreMessaging_Messages(
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
     			    @OriginalTo,
					@From,
				    @OriginalSubject,
					@Body,
					@ConversationID,
					@ReplyAllAllowed,
					@SenderUserID,
                    @CreateUpdateUserID , -- CreatedBy - int
                    GETUTCDATE() , -- CreatedOn - datetime
                    @CreateUpdateUserID , -- LastModifiedBy - int
                    GETDATE() -- LastModifiedOn - datetime
                    )

	SELECT @NewMessageID = SCOPE_IDENTITY()

	IF (@ReplyAllAllowed = 0) --original message was sent to a Role, reply will be sent to the original sender only
	BEGIN
		INSERT INTO dbo.dnn_CoreMessaging_MessageRecipients
		        ( [MessageID],
		          [UserID],
		          [Read],
		          [Archived],
		          CreatedByUserID,
		          CreatedOnDate,
		          LastModifiedByUserID,
		          LastModifiedOnDate
		        )
		VALUES  ( @NewMessageID, -- MessageID - int
		          @OriginalSenderUserID, -- UserID - int
		          0, -- Read - bit
		          0, -- Archived - bit
		          @CreateUpdateUserID , -- CreatedByUserID - int
		          GETDATE() , -- CreatedOnDate - datetime
		          @CreateUpdateUserID , -- LastModifiedByUserID - int
		          GETDATE()  -- LastModifiedOnDate - datetime
		        )
        
        IF @OriginalSenderUserID <> @SenderUserID
        BEGIN
            INSERT INTO dbo.dnn_CoreMessaging_MessageRecipients
		            ( [MessageID],
		              [UserID],
		              [Read],
		              [Archived],
		              CreatedByUserID,
		              CreatedOnDate,
		              LastModifiedByUserID,
		              LastModifiedOnDate
		            )
		    VALUES  ( @NewMessageID, -- MessageID - int
		              @SenderUserID, -- UserID - int
		              1, -- Read - bit
		              0, -- Archived - bit
		              @CreateUpdateUserID , -- CreatedByUserID - int
		              GETDATE() , -- CreatedOnDate - datetime
		              @CreateUpdateUserID , -- LastModifiedByUserID - int
		              GETDATE()  -- LastModifiedOnDate - datetime
		            )
        END
	END
	ELSE --Reply should be sent to all the original Recipients
	BEGIN
		INSERT dbo.dnn_CoreMessaging_MessageRecipients(
			[MessageID],
			[UserID],
			[Read],
			[Archived],
            [CreatedByUserID],
            [CreatedOnDate],
            [LastModifiedByUserID],
            [LastModifiedOnDate]
            )
			SELECT
			  @NewMessageID,
			  UserID,
			  0,
			  0,
              @CreateUpdateUserID , -- CreatedBy - int
              GETDATE() , -- CreatedOn - datetime
              @CreateUpdateUserID , -- LastModifiedBy - int
              GETDATE() -- LastModifiedOn - datetime
           FROM dbo.dnn_CoreMessaging_MessageRecipients
           WHERE MessageID = @ConversationID
	END

	SELECT  @NewMessageID

