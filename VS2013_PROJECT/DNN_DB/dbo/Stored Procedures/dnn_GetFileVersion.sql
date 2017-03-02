CREATE PROCEDURE [dbo].[dnn_GetFileVersion] 
	@FileId int,
	@Version int
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
	WHERE FileId = @FileId
	  AND Version = @Version
END

