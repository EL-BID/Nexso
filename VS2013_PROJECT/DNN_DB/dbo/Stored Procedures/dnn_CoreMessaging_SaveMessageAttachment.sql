CREATE PROCEDURE [dbo].[dnn_CoreMessaging_SaveMessageAttachment]
    @MessageAttachmentID int,
    @MessageID int,
    @FileID int,
	@CreateUpdateUserID INT
AS
    IF ( @MessageAttachmentID = -1 )
        BEGIN
            INSERT dbo.dnn_CoreMessaging_MessageAttachments(
					[FileID],
					[MessageID],
                    [CreatedByUserID],
                    [CreatedOnDate],
                    [LastModifiedByUserID],
                    [LastModifiedOnDate]
                    )
            VALUES  (
					@FileID,
					@MessageID,
                    @CreateUpdateUserID , -- CreatedBy - int
                    GETDATE() , -- CreatedOn - datetime
                    @CreateUpdateUserID , -- LastModifiedBy - int
                    GETDATE() -- LastModifiedOn - datetime
                    )

            SELECT  @MessageAttachmentID = SCOPE_IDENTITY()
        END
    ELSE
        BEGIN
            UPDATE  dbo.dnn_CoreMessaging_MessageAttachments
            SET     [FileID] = @FileID,
					[MessageID] = @MessageID,
                    LastModifiedByUserID = @CreateUpdateUserID,
                    LastModifiedOnDate = GETDATE()
            WHERE   MessageAttachmentID = @MessageAttachmentID
        END

    SELECT  @MessageAttachmentID

