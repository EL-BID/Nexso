CREATE PROCEDURE [dbo].[dnn_GetFileVersionsInFolder]
@FolderId int
AS
BEGIN
	SELECT 
	   fv.[FileId]
      ,fv.[Version]
      ,fv.[FileName]
      ,fv.[Extension]
      ,fv.[Size]
      ,fv.[Width]
      ,fv.[Height]
      ,fv.[ContentType]
      ,fv.[CreatedByUserID]
      ,fv.[CreatedOnDate]
      ,fv.[LastModifiedByUserID]
      ,fv.[LastModifiedOnDate]
      ,fv.[SHA1Hash]
	FROM dbo.dnn_FileVersions fv, dbo.dnn_Files f
    WHERE fv.FileId = f.FileId and f.FolderId = @FolderId
END

