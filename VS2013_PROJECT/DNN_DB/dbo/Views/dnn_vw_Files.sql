CREATE VIEW [dbo].[dnn_vw_Files]
AS
	SELECT	fi.FileId, 
			fi.PortalId, 
			fi.FileName, 
			fi.Extension, 
			fi.Size, 
			fi.Width, 
			fi.Height, 
			fi.ContentType, 
			fi.FolderID, 
			fi.[Content], 
			fi.CreatedByUserID, 
			fi.CreatedOnDate, 
			fi.LastModifiedByUserID, 
			fi.LastModifiedOnDate, 
			fi.UniqueId, 
			fi.VersionGuid, 
			fi.SHA1Hash, 
			fi.LastModificationTime, 
			fi.Title, 
			fi.StartDate, 
			fi.EnablePublishPeriod, 
			fi.EndDate, 
			fi.ContentItemID, 
			fi.PublishedVersion, 
			fo.FolderPath AS Folder,
			fo.IsCached,
			fo.FolderMappingID,
			fo.StorageLocation
	FROM         dbo.[dnn_Files] AS fi 
	INNER JOIN dbo.[dnn_Folders] AS fo 
		ON fi.FolderID = fo.FolderID

