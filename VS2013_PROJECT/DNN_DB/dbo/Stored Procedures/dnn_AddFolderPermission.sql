CREATE PROCEDURE [dbo].[dnn_AddFolderPermission]
    @FolderID           Int, -- not Null!
    @PermissionId       Int, -- not Null!
    @RoleId             Int, -- might be negative for virtual roles
    @AllowAccess        Bit, -- false: deny, true: grant
    @UserId             Int, -- -1 is replaced by Null
    @CreatedByUserId    Int  -- -1 is replaced by Null
AS
BEGIN
    INSERT INTO dbo.[dnn_FolderPermission] (
        [FolderID],
        [PermissionID],
        [RoleId],
        [AllowAccess],
        [UserId],
        [CreatedByUserId],
        [CreatedOnDate],
        [LastModifiedByUserId],
        [LastModifiedOnDate]
    ) VALUES (
        @FolderID,
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

