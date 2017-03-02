CREATE procedure [dbo].[dnn_DeleteTabPermissionsByUserID]
	@PortalID int,
	@UserID int
AS
	DELETE FROM dbo.dnn_TabPermission
		FROM dbo.dnn_TabPermission TP
			INNER JOIN dbo.dnn_Tabs AS T ON TP.TabID = T.TabID
		WHERE T.PortalID = @PortalID
		AND TP.UserID = @UserID

