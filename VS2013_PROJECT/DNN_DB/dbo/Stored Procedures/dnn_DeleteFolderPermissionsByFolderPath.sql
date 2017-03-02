CREATE PROCEDURE [dbo].[dnn_DeleteFolderPermissionsByFolderPath]
    @PortalId   Int,            -- Null for Host menu tabs
    @FolderPath nVarChar(300)   -- must be a valid path
AS
BEGIN
    DELETE FROM dbo.[dnn_FolderPermission]
    WHERE FolderID IN (SELECT FolderID FROM dbo.[dnn_Folders]
                                       WHERE FolderPath = @FolderPath AND (IsNull(PortalID, -1) = IsNull(@PortalId, -1)))
END

