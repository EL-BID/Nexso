CREATE PROCEDURE [dbo].[dnn_AddFolder]
	@PortalID 			int,
	@UniqueId	 		uniqueidentifier,
	@VersionGuid 		uniqueidentifier,
	@FolderPath 		nvarchar(300),
	@MappedPath 		nvarchar(300),
	@StorageLocation 	int,
	@IsProtected 		bit,
	@IsCached 			bit,
	@LastUpdated 		datetime,
	@CreatedByUserID  	int,
	@FolderMappingID	int = 0,
	@IsVersioned		bit = 0,
	@WorkflowID			int = NULL,
	@ParentID			int = NULL
AS
BEGIN
	IF @FolderMappingID = 0 BEGIN
		SELECT @FolderMappingID = FM.FolderMappingID
		FROM dbo.[dnn_FolderMappings] as FM
		WHERE ISNULL(FM.PortalID, -1) = ISNULL(@PortalID, -1)
		AND FolderProviderType = (
			CASE @StorageLocation
				WHEN 0 THEN 'StandardFolderProvider'
				WHEN 1 THEN 'SecureFolderProvider'
				WHEN 2 THEN 'DatabaseFolderProvider'
				ELSE 'StandardFolderProvider'
			END
		)
	END
	
	INSERT INTO dbo.[dnn_Folders] (
		PortalID, 
		UniqueId,
		VersionGuid,
		FolderPath,
		MappedPath, 
		StorageLocation, 
		IsProtected, 
		IsCached, 
		LastUpdated,
		CreatedByUserID,
		CreatedOnDate,
		LastModifiedByUserID,
		LastModifiedOnDate,
		FolderMappingID,
		IsVersioned,
		WorkflowID,
		ParentID
	)
	VALUES (
		@PortalID, 
		@UniqueId,
		@VersionGuid,
		@FolderPath,
		@MappedPath, 
		@StorageLocation, 
		@IsProtected, 
		@IsCached, 
		@LastUpdated,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate(),
		@FolderMappingID,
		@IsVersioned,
		@WorkflowID,
		@ParentID
	)
	
	DECLARE @FolderId INT
    SELECT @FolderId = SCOPE_IDENTITY()
  
    SELECT @FolderId
END

