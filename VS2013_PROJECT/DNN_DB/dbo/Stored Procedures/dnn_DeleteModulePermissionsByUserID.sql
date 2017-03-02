CREATE procedure [dbo].[dnn_DeleteModulePermissionsByUserID]
	@PortalID int,
	@UserID int
AS
	DELETE FROM dbo.dnn_ModulePermission
		FROM dbo.dnn_ModulePermission MP
			INNER JOIN dbo.dnn_Modules AS M ON MP.ModuleID = M.ModuleID
		WHERE M.PortalID = @PortalID
		AND MP.UserID = @UserID

