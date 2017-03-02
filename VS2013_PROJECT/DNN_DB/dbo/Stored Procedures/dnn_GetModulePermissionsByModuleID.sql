CREATE PROCEDURE [dbo].[dnn_GetModulePermissionsByModuleID]
    @ModuleId       Int,   -- Null|-1 for all modules
    @PermissionId   Int    -- Null|-1 for all permissions
AS
BEGIN
	IF (IsNull(@ModuleId, -1) = -1) -- separate branches with individual query optimization
		SELECT *
		  FROM dbo.[dnn_vw_ModulePermissions]
		 WHERE (PermissionID = @PermissionId OR IsNull(@PermissionId, -1) = -1)
	 ELSE
		SELECT *
		FROM dbo.[dnn_vw_ModulePermissions]
		WHERE ((ModuleID = @ModuleId) OR (ModuleID IS NULL AND PermissionCode = 'SYSTEM_MODULE_DEFINITION'))
		AND (PermissionID = @PermissionId OR IsNull(@PermissionId, -1) = -1)
END

