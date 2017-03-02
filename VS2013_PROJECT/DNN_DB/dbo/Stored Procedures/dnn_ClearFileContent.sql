CREATE PROCEDURE [dbo].[dnn_ClearFileContent]

	@FileId      int

AS

UPDATE dbo.dnn_Files
	SET    Content = NULL
	WHERE  FileId = @FileId

