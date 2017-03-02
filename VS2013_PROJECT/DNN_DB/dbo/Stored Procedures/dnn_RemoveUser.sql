CREATE PROCEDURE [dbo].[dnn_RemoveUser]
	@UserID		int,
	@PortalID   int
AS
	IF @PortalID IS NULL
		BEGIN
			-- Delete SuperUser
			DELETE FROM dbo.dnn_Users
				WHERE  UserId = @UserID
		END
	ELSE
		BEGIN
			-- Remove User from Portal
			DELETE FROM dbo.dnn_UserPortals
				WHERE  UserId = @UserID
                 AND PortalId = @PortalID
			IF NOT EXISTS (SELECT 1 FROM dbo.dnn_UserPortals WHERE  UserId = @UserID)
				-- Delete User (but not if SuperUser)
				BEGIN
					DELETE FROM dbo.dnn_Users
						WHERE  UserId = @UserID
							AND IsSuperUser = 0
					DELETE FROM dbo.dnn_UserRoles
						WHERE  UserID = @UserID
				END
			ELSE
				BEGIN
					DELETE ur FROM dbo.dnn_UserRoles ur
						INNER JOIN dbo.dnn_Roles r ON r.RoleID = ur.RoleID
						WHERE  UserID = @UserID AND r.PortalID = @PortalID
				END
		END
