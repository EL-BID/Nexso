CREATE PROCEDURE [dbo].[dnn_UpdateFolderMapping]
	@FolderMappingID int,
	@MappingName nvarchar(50),
	@Priority int,
	@LastModifiedByUserID int
AS
BEGIN
	UPDATE dbo.[dnn_FolderMappings]
	SET
		MappingName = @MappingName,
		Priority = @Priority,
		LastModifiedByUserID = @LastModifiedByUserID,
		LastModifiedOnDate = GETDATE()
	WHERE FolderMappingID = @FolderMappingID
END

