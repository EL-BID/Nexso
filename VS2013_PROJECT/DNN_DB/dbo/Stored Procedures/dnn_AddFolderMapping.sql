CREATE PROCEDURE [dbo].[dnn_AddFolderMapping]
	@PortalID int,
	@MappingName nvarchar(50),
	@FolderProviderType nvarchar(50),
	@CreatedByUserID int
AS
BEGIN
	DECLARE @Priority int

	SELECT TOP 1 @Priority = Priority + 1
	FROM dbo.[dnn_FolderMappings]
	WHERE [PortalID] = @PortalID
	ORDER BY Priority DESC

	INSERT INTO dbo.[dnn_FolderMappings] (
		PortalID,
		MappingName,
		FolderProviderType,
		Priority,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate
	)
	VALUES (
		@PortalID,
		@MappingName,
		@FolderProviderType,
		@Priority,
		@CreatedByUserID,
		GETDATE(),
		@CreatedByUserID,
		GETDATE()
	)

	SELECT SCOPE_IDENTITY()
END

