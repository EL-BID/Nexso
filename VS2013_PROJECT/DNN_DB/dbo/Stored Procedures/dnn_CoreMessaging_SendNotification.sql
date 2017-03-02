CREATE PROCEDURE [dbo].[dnn_CoreMessaging_SendNotification]
	@NotificationTypeID int,
	@PortalID INT,
	@To nvarchar(2000),
	@From nvarchar(200),
    @Subject nvarchar(400),
    @Body nvarchar(max),
    @SenderUserID int,
	@CreateUpdateUserID int,
	@ExpirationDate datetime,
    @IncludeDismissAction bit,
    @Context nvarchar(200)
AS
BEGIN
	INSERT dbo.[dnn_CoreMessaging_Messages] (
		[NotificationTypeID],
		[PortalID],
		[To],
		[From],
		[Subject],
		[Body],
		[SenderUserID],
		[ExpirationDate],
        [IncludeDismissAction],
        [Context],
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	) VALUES (
		@NotificationTypeID,
		@PortalID,
		@To,
		@From,
		@Subject,
		@Body,
		@SenderUserID,
		@ExpirationDate,
        @IncludeDismissAction,
        @Context,
		@CreateUpdateUserID, -- CreatedBy
		GETUTCDATE(), -- CreatedOn
		@CreateUpdateUserID, -- LastModifiedBy
		GETDATE() -- LastModifiedOn
	)

	SELECT  SCOPE_IDENTITY()
END

