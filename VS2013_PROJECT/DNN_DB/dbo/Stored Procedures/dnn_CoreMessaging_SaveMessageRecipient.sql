CREATE PROCEDURE [dbo].[dnn_CoreMessaging_SaveMessageRecipient]
    @RecipientID int,
    @MessageID int,
    @UserID int,
    @Read bit,
	@Archived bit,
	@CreateUpdateUserID INT
AS
BEGIN
    IF ( @RecipientID = -1 )
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
            VALUES  (
					@MessageID,
					@UserID,
					@Read,
					@Archived,
                    @CreateUpdateUserID , -- CreatedBy - int
                    GETDATE(), -- CreatedOn - datetime
                    @CreateUpdateUserID , -- LastModifiedBy - int
                    GETDATE() -- LastModifiedOn - datetime
                    )

            SELECT  @RecipientID = SCOPE_IDENTITY()
        END
    ELSE
        BEGIN
            UPDATE  dbo.dnn_CoreMessaging_MessageRecipients
            SET     [MessageID] = @MessageID,
					[UserID] = @UserID,
					[Read] = @Read,
					[Archived] = @Archived,
                    LastModifiedByUserID = @CreateUpdateUserID,
                    LastModifiedOnDate = GETDATE()
            WHERE   RecipientID = @RecipientID
        END

    SELECT  @RecipientID
END

