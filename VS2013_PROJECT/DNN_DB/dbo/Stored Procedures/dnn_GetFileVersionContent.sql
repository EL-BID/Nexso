CREATE PROCEDURE [dbo].[dnn_GetFileVersionContent]

	@FileId		int,
	@Version	int

AS
	SELECT Content
	FROM dbo.[dnn_FileVersions]
	WHERE FileId = @FileId
		AND Version = @Version

