CREATE PROCEDURE [dbo].[dnn_UpdateOnlineUser]
@UserID 	INT,
@PortalID 	INT,
@TabID 		INT,
@LastActiveDate DATETIME 
AS
BEGIN
	IF EXISTS (SELECT UserID FROM dbo.dnn_Users WHERE UserID = @UserID)
	BEGIN
		IF EXISTS (SELECT UserID FROM dbo.dnn_UsersOnline WHERE UserID = @UserID and PortalID = @PortalID)
			UPDATE 
				dbo.dnn_UsersOnline
			SET 
				TabID = @TabID,
				LastActiveDate = @LastActiveDate
			WHERE
				UserID = @UserID
				and 
				PortalID = @PortalID
		ELSE
			INSERT INTO
				dbo.dnn_UsersOnline
				(UserID, PortalID, TabID, CreationDate, LastActiveDate) 
			VALUES
				(@UserID, @PortalID, @TabID, GetDate(), @LastActiveDate)
	END

END

