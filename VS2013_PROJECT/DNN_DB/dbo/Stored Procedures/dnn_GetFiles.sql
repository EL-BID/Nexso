CREATE PROCEDURE [dbo].[dnn_GetFiles]
    @FolderID Int,                      -- not null!
    @RetrieveUnpublishedFiles Bit = 0   -- include files, hidden by status or date?
AS
	IF @RetrieveUnpublishedFiles = 0 
	BEGIN
		SELECT
			F.FileId,
			F.PortalId,
			F.[FileName],
			F.Extension,
			F.[Size],
			F.Width,
			F.Height,
			F.ContentType,
			F.FolderID,
			F.Folder,
			F.StorageLocation,
			F.IsCached,
			F.FolderMappingID,
			F.UniqueId,
			F.VersionGuid,
			F.SHA1Hash,
			F.LastModificationTime,
			F.Title,
			F.EnablePublishPeriod,
			F.StartDate,
			F.EndDate,
			F.CreatedByUserID,
			F.CreatedOnDate,
			F.LastModifiedByUserID,
			F.LastModifiedOnDate,
			F.PublishedVersion,
			F.ContentItemID
		FROM dbo.[dnn_vw_PublishedFiles] F			
		WHERE F.FolderID = @FolderID
		ORDER BY [FolderID], [FileName]
	END
	ELSE BEGIN
		SELECT
			F.FileId,
			F.PortalId,
			F.[FileName],
			F.Extension,
			F.[Size],
			F.Width,
			F.Height,
			F.ContentType,
			F.FolderID,
			F.Folder,
			F.StorageLocation,
			F.IsCached,
			F.FolderMappingID,
			F.UniqueId,
			F.VersionGuid,
			F.SHA1Hash,
			F.LastModificationTime,
			F.Title,
			F.EnablePublishPeriod,
			F.StartDate,
			F.EndDate,
			F.CreatedByUserID,
			F.CreatedOnDate,
			F.LastModifiedByUserID,
			F.LastModifiedOnDate,
			F.PublishedVersion,
			F.ContentItemID
		FROM dbo.[dnn_vw_Files] F			
		WHERE F.FolderID = @FolderID
		ORDER BY [FolderID], [FileName]
	END

