CREATE PROCEDURE [dbo].[dnn_AddListEntry]

	@ListName nvarchar(50), 
	@Value nvarchar(100), 
	@Text nvarchar(150),
	@ParentID int,
	@Level int, 
	@EnableSortOrder bit,
	@DefinitionID int, 
	@Description nvarchar(500),
	@PortalID int,
	@SystemList bit,
	@CreatedByUserID	int

AS
	DECLARE @SortOrder int

	IF @EnableSortOrder = 1
		SET @SortOrder = IsNull((SELECT MAX ([SortOrder]) From dbo.[dnn_Lists] Where [ListName] = @ListName), 0) + 1
	ELSE
		SET @SortOrder = 0

	-- Check if this entry exists
	If EXISTS (SELECT [EntryID] From dbo.[dnn_Lists] WHERE [ListName] = @ListName And [Value] = @Value And [Text] = @Text And [ParentID] = @ParentID)
	BEGIN
		SELECT -1
		RETURN 
	END

	INSERT INTO dbo.[dnn_Lists] 
		(
  		[ListName],
		[Value],
		[Text],
		[Level],
		[SortOrder],
		[DefinitionID],
		[ParentID],
		[Description],
		[PortalID],
		[SystemList],
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
		)
	VALUES (
		@ListName,
		@Value,
		@Text,
		@Level,
		@SortOrder,
		@DefinitionID,
		@ParentID,
		@Description,
		@PortalID,
		@SystemList,
  		@CreatedByUserID,
	  	getdate(),
	  	@CreatedByUserID,
	  	getdate()	
		)

	SELECT SCOPE_IDENTITY()

