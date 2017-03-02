CREATE PROCEDURE [dbo].[dnn_DeleteRole]
    @RoleId Int -- ID of role to delete. System Roles ignored (deletion of system roles not supported)
AS
BEGIN
    IF @RoleId >= 0 BEGIN
        DELETE FROM dbo.[dnn_DesktopModulePermission] WHERE RoleID = @RoleId
        DELETE FROM dbo.[dnn_FolderPermission]        WHERE RoleID = @RoleId
        DELETE FROM dbo.[dnn_ModulePermission]        WHERE RoleID = @RoleId
        DELETE FROM dbo.[dnn_TabPermission]           WHERE RoleID = @RoleId
        DELETE FROM dbo.[dnn_Roles]                   WHERE RoleID = @RoleId
    END
END

