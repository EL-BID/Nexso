CREATE PROCEDURE [dbo].[dnn_GetFile]
	@FileName nvarchar(246),
	@FolderID int,
	@RetrieveUnpublishedFiles bit = 0
AS
BEGIN
	IF @RetrieveUnpublishedFiles = 0 BEGIN
		SELECT FileId,
			   PortalId,
			   [FileName],
			   Extension,
			   Size,
			   Width,
			   Height,
			   ContentType,
			   FolderID,
			   Folder,
			   StorageLocation,
			   IsCached,
			   UniqueId,
			   VersionGuid,	   
			   SHA1Hash,
			   FolderMappingID,
			   LastModificationTime,
			   Title,
			   EnablePublishPeriod,
			   StartDate,
			   EndDate,
			   CreatedByUserID,
			   CreatedOnDate,
			   LastModifiedByUserID,
			   LastModifiedOnDate,
			   ContentItemID,
			   PublishedVersion
		FROM dbo.[dnn_vw_PublishedFiles] 			
		WHERE [FileName] = @FileName AND FolderID = @FolderID
	END
	ELSE BEGIN
		SELECT FileId,
			   PortalId,
			   [FileName],
			   Extension,
			   Size,
			   Width,
			   Height,
			   ContentType,
			   FolderID,
			   Folder,
			   StorageLocation,
			   IsCached,
			   UniqueId,
			   VersionGuid,	   
			   SHA1Hash,
			   FolderMappingID,
			   LastModificationTime,
			   Title,
			   EnablePublishPeriod,
			   StartDate,
			   EndDate,
			   CreatedByUserID,
			   CreatedOnDate,
			   LastModifiedByUserID,
			   LastModifiedOnDate,
			   ContentItemID,
			   PublishedVersion
		FROM dbo.[dnn_vw_Files]
		WHERE [FileName] = @FileName AND FolderID = @FolderID
	END
END

