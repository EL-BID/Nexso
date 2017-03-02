CREATE PROCEDURE [dbo].[dnn_GetFileContent]
	@FileId int
AS
BEGIN
	SELECT Content
	FROM dbo.[dnn_Files]
	WHERE FileId = @FileId
END

