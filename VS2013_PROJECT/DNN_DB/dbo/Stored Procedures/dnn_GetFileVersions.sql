CREATE PROCEDURE [dbo].[dnn_GetFileVersions] 
@FileId int
AS
BEGIN
	SELECT 
	   [FileId]
      ,[Version]
      ,[FileName]
      ,[Extension]
      ,[Size]
      ,[Width]
      ,[Height]
      ,[ContentType]
      ,[CreatedByUserID]
      ,[CreatedOnDate]
      ,[LastModifiedByUserID]
      ,[LastModifiedOnDate]
      ,[SHA1Hash]
	FROM dbo.dnn_FileVersions fv
	WHERE fv.FileId = @FileId
END

