CREATE PROCEDURE [dbo].[dnn_GetFolders]
	@PortalID int -- Null|-1: Host Portal
AS
BEGIN
	SELECT *
	FROM dbo.dnn_Folders
	WHERE IsNull(PortalID, -1) = IsNull(@PortalID, -1) 
	ORDER BY PortalID, FolderPath -- include portalId to use proper index
END

