CREATE procedure [dbo].[dnn_UpdateListEntry]
	
	@EntryID int, 
	@Value nvarchar(100), 
	@Text nvarchar(150), 
	@Description nvarchar(500),
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_Lists
		SET	
			[Value] = @Value,
			[Text] = @Text,	
			[Description] = @Description,
			[LastModifiedByUserID] = @LastModifiedByUserID,	
			[LastModifiedOnDate] = getdate()
		WHERE 	[EntryID] = @EntryID

