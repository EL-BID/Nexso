CREATE PROCEDURE [dbo].[dnn_GetLegacyFolderCount]
AS
	SELECT COUNT(*)
	FROM dbo.dnn_Folders
		WHERE ParentID IS NULL AND FolderPath <> ''

