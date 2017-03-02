CREATE PROCEDURE [dbo].[dnn_RestoreUser]
	@UserID		int,
	@PortalID   int
AS
	IF @PortalID IS NULL
		BEGIN
			UPDATE dbo.dnn_Users
				SET	IsDeleted = 0
				WHERE  UserId = @UserID
		END
	ELSE
		BEGIN
			UPDATE dbo.dnn_UserPortals
				SET IsDeleted = 0
				WHERE  UserId = @UserID
					AND PortalId = @PortalID
	END

