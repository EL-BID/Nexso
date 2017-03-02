CREATE PROCEDURE [dbo].[dnn_UpdateDesktopModulePermission]
    @DesktopModulePermissionId Int, -- not null!
    @PortalDesktopModuleId     Int, -- not null!
    @PermissionId              Int, -- not null!
    @RoleId                    Int, -- might be negative for virtual roles
    @AllowAccess               Bit, -- false: deny, true: grant
    @UserId                    Int, -- -1 is replaced by Null
    @LastModifiedByUserId      Int  -- -1 is replaced by Null
AS
    UPDATE dbo.[dnn_DesktopModulePermission]
    SET
        [PortalDesktopModuleId] = @PortalDesktopModuleId,
        [PermissionId]          = @PermissionId,
        [RoleId]                = @RoleId,
        [AllowAccess]           = @AllowAccess,
        [UserId]                = CASE WHEN @UserId = -1 THEN Null ELSE @UserId  END,
        [LastModifiedByUserId]  = CASE WHEN @LastModifiedByUserId = -1 THEN Null ELSE @LastModifiedByUserId  END,
        [LastModifiedOnDate]    = GetDate()
    WHERE [DesktopModulePermissionId] = @DesktopModulePermissionId

