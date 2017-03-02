CREATE PROCEDURE [dbo].[dnn_AddUserPortal]

	@PortalID		int,
	@UserID			int
AS

	IF not exists ( SELECT 1 FROM dbo.dnn_UserPortals WHERE UserID = @UserID AND PortalID = @PortalID ) AND @PortalID > -1
		BEGIN
			INSERT INTO dbo.dnn_UserPortals (
				UserID,
				PortalID,
				Authorised,
				CreatedDate
			)
			VALUES (
				@UserID,
				@PortalID,
				1,
				getdate()
			)
		END

