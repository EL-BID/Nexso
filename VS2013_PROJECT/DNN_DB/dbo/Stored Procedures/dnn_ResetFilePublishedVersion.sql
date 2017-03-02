CREATE PROCEDURE [dbo].[dnn_ResetFilePublishedVersion] 
@FileId int
AS
BEGIN
	UPDATE dbo.dnn_Files
		SET PublishedVersion = 1
		WHERE FileId = @FileId
END

