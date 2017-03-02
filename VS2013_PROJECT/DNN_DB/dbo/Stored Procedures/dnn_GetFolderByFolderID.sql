CREATE PROCEDURE [dbo].[dnn_GetFolderByFolderID]
	@FolderID int
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_Folders]
	WHERE FolderID = @FolderID
END

