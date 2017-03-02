CREATE PROCEDURE [dbo].[dnn_DeleteFolderPermissionsByUserID]
    @PortalId Int,  -- Null|-1 for Host menu tabs
    @UserId   Int   -- Not Null
AS
    DELETE FROM dbo.[dnn_FolderPermission]
    WHERE UserID = @UserId
     AND FolderID IN (SELECT FolderID FROM dbo.[dnn_Folders] 
	                  WHERE (PortalID = @PortalId Or IsNull(@PortalId, -1) = IsNull(PortalID, -1)))

