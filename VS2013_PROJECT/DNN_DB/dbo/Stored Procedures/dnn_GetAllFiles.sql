CREATE PROCEDURE [dbo].[dnn_GetAllFiles]
AS
BEGIN
	SELECT   
	  FileId,  
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
	  PublishedVersion,  
	  ContentItemID
	FROM dbo.[dnn_vw_Files] 	
END

