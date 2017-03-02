CREATE PROCEDURE [dbo].[dnn_AddContentWorkflowStatePermission]
	@StateID int,
	@PermissionID int,
	@RoleID int,
	@AllowAccess bit,
	@UserID int,
	@CreatedByUserID int
AS

	INSERT INTO dbo.dnn_ContentWorkflowStatePermission (
		[StateID],
		[PermissionID],
		[RoleID],
		[AllowAccess],
		[UserID],
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	) VALUES (
		@StateID,
		@PermissionID,
		@RoleID,
		@AllowAccess,
		@UserID,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

	SELECT SCOPE_IDENTITY()

