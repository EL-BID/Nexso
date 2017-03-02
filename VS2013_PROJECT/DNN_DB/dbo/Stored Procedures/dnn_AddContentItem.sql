CREATE PROCEDURE [dbo].[dnn_AddContentItem] 
	@Content			nvarchar(max),
	@ContentTypeID		int,
	@TabID				int,
	@ModuleID			int, 
	@ContentKey			nvarchar(250),
	@Indexed			bit,
	@CreatedByUserID	int,
	@StateID			int = NULL
AS
	INSERT INTO dbo.[dnn_ContentItems] (
		Content,
		ContentTypeID,
		TabID,
		ModuleID,
		ContentKey,
		Indexed,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate,
		StateID
	)

	VALUES (
		@Content,
		@ContentTypeID,
		@TabID,
		@ModuleID,
		@ContentKey,
		@Indexed,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate(),
		@StateID
	)

	SELECT SCOPE_IDENTITY()

