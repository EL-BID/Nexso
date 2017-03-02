CREATE PROCEDURE [dbo].[dnn_AddDesktopModulePermission]
    @PortalDesktopModuleID Int, -- not null!
    @PermissionId          Int, -- not null!
    @RoleId                Int, -- might be negative for virtual roles
    @AllowAccess           Bit, -- false: deny, true: grant
    @UserId                Int, -- -1 is replaced by Null
    @CreatedByUserId       Int  -- -1 is replaced by Null
AS
BEGIN
    INSERT INTO dbo.[dnn_DesktopModulePermission] (
        [PortalDesktopModuleID],
        [PermissionID],
        [RoleID],
        [AllowAccess],
        [UserID],
        [CreatedByUserID],
        [CreatedOnDate],
        [LastModifiedByUserID],
        [LastModifiedOnDate]
    ) VALUES (
        @PortalDesktopModuleID,
        @PermissionID,
        @RoleId,
        @AllowAccess,
        CASE WHEN @UserId = -1 THEN Null ELSE @UserId END,
        CASE WHEN @CreatedByUserID = -1 THEN Null ELSE @CreatedByUserID END,
        GetDate(),
        CASE WHEN @CreatedByUserID = -1 THEN Null ELSE @CreatedByUserID END,
        GetDate()
    )
    SELECT SCOPE_IDENTITY()
END

