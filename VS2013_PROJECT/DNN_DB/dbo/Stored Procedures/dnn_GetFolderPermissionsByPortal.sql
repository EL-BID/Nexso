CREATE PROCEDURE [dbo].[dnn_GetFolderPermissionsByPortal]
    @PortalId Int   -- Null|-1 for Host menu tabs
AS
    SELECT *
    FROM dbo.[dnn_vw_FolderPermissions]
    WHERE IsNull(PortalID, -1) = IsNull(@PortalId, -1)

