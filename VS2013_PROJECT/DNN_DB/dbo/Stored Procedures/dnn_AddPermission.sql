CREATE PROCEDURE [dbo].[dnn_AddPermission]
	@ModuleDefID		int,
	@PermissionCode		varchar(50),
	@PermissionKey		varchar(50),
	@PermissionName		varchar(50),
	@CreatedByUserID	int
AS

INSERT INTO dbo.dnn_Permission (
	[ModuleDefID],
	[PermissionCode],
	[PermissionKey],
	[PermissionName],
	[CreatedByUserID],
	[CreatedOnDate],
	[LastModifiedByUserID],
	[LastModifiedOnDate]
) VALUES (
	@ModuleDefID,
	@PermissionCode,
	@PermissionKey,
	@PermissionName,
	@CreatedByUserID,
	getdate(),
	@CreatedByUserID,
	getdate()
)

select SCOPE_IDENTITY()

