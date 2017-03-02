CREATE PROCEDURE [dbo].[dnn_UpdateContentWorkflowStatePermission]
	@WorkflowStatePermissionID int, 
	@StateID int, 
	@PermissionID int, 
	@RoleID int ,
	@AllowAccess bit,
    @UserID int,
	@LastModifiedByUserID	int
AS
    UPDATE dbo.dnn_ContentWorkflowStatePermission 
    SET     
	    [StateID] = @StateID,
	    [PermissionID] = @PermissionID,
	    [RoleID] = @RoleID,
	    [AllowAccess] = @AllowAccess,
        [UserID] = @UserID,
        [LastModifiedByUserID] = @LastModifiedByUserID,
	    [LastModifiedOnDate] = getdate()
    WHERE
		[WorkflowStatePermissionID] = @WorkflowStatePermissionID

