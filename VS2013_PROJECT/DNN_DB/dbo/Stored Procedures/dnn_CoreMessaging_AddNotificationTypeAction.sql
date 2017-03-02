CREATE PROCEDURE [dbo].[dnn_CoreMessaging_AddNotificationTypeAction]
	@NotificationTypeID int,
	@NameResourceKey nvarchar(100),
	@DescriptionResourceKey nvarchar(100),
	@ConfirmResourceKey nvarchar(100),
	@APICall nvarchar(500),
	@CreatedByUserID int
AS
BEGIN
	DECLARE @Order int 
	
	SELECT @Order = MAX([Order])
	FROM dbo.[dnn_CoreMessaging_NotificationTypeActions]
	WHERE [NotificationTypeID] = @NotificationTypeID
	
	IF @Order IS NULL
		SET @Order = 1
	ELSE
		SET @Order = @Order + 2
		
	INSERT INTO dbo.[dnn_CoreMessaging_NotificationTypeActions] (
		[NotificationTypeID],
		[NameResourceKey],
		[DescriptionResourceKey],
		[ConfirmResourceKey],
		[Order],
		[APICall],
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	) VALUES (
		@NotificationTypeID,
		@NameResourceKey,
		@DescriptionResourceKey,
		@ConfirmResourceKey,
		@Order,
		@APICall,
		@CreatedByUserID,
		GETDATE(),
		@CreatedByUserID,
		GETDATE()
	)
	
	SELECT SCOPE_IDENTITY()
END

