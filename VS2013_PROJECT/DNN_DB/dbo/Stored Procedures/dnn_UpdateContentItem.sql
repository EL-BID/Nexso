CREATE PROCEDURE [dbo].[dnn_UpdateContentItem] 
	@ContentItemID			int,
	@Content				nvarchar(max),
	@ContentTypeID			int,
	@TabID					int,
	@ModuleID				int, 
	@ContentKey				nvarchar(250),
	@Indexed				bit,
	@LastModifiedByUserID	int,
	@StateID				int = NULL
AS
	UPDATE dbo.[dnn_ContentItems] 
		SET 
			Content = @Content,
			ContentTypeID = @ContentTypeID,
			TabID = @TabID,
			ModuleID = @ModuleID,
			ContentKey = @ContentKey,
			Indexed = @Indexed,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate(),
			StateID = @StateID
	WHERE ContentItemId = @ContentItemId

