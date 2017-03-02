CREATE PROCEDURE [dbo].[dnn_UpdatePermission]
	@PermissionID			int, 
	@PermissionCode			varchar(50),
	@ModuleDefID			int, 
	@PermissionKey			varchar(50), 
	@PermissionName			varchar(50),
	@LastModifiedByUserID	int
AS

UPDATE dbo.dnn_Permission SET
	[ModuleDefID] = @ModuleDefID,
	[PermissionCode] = @PermissionCode,
	[PermissionKey] = @PermissionKey,
	[PermissionName] = @PermissionName,
	[LastModifiedByUserID] = @LastModifiedByUserID,
	[LastModifiedOnDate] = getdate()
WHERE
	[PermissionID] = @PermissionID

