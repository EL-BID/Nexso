CREATE PROCEDURE [dbo].[dnn_GetFolderMappings]
	@PortalID int
AS
BEGIN
	SELECT *
	FROM dbo.[dnn_FolderMappings]
	WHERE ISNULL(PortalID, -1) = ISNULL(@PortalID, -1)
	ORDER BY Priority
END

