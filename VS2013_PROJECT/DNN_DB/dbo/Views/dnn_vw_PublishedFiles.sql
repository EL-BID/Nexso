CREATE VIEW [dbo].[dnn_vw_PublishedFiles]
AS
	SELECT     
	   fi.[FileId]
      ,fi.[PortalId]
      ,fi.[FileName]
      ,fi.[Extension]
      ,fi.[Size]
      ,fi.[Width]
      ,fi.[Height]
      ,fi.[ContentType]
      ,fi.[FolderID]
      ,fi.[Content]
      ,fi.[CreatedByUserID]
      ,fi.[CreatedOnDate]
      ,fi.[LastModifiedByUserID]
      ,fi.[LastModifiedOnDate]
      ,fi.[UniqueId]
      ,fi.[VersionGuid]
      ,fi.[SHA1Hash]
      ,fi.[LastModificationTime]
      ,fi.[Title]
      ,fi.[StartDate]
      ,fi.[EnablePublishPeriod]
      ,fi.[EndDate]
      ,fi.[ContentItemID]
      ,fi.[PublishedVersion]
	  ,fi.[Folder]
	  ,fi.[IsCached]
	  ,fi.[StorageLocation]
	  ,fi.[FolderMappingID]
	FROM       dbo.[dnn_vw_Files] fi
	  WHERE [EnablePublishPeriod] = 0 
		 OR ([StartDate] <= GETDATE()
			AND ([EndDate] IS NULL OR GETDATE() <= [EndDate]))

