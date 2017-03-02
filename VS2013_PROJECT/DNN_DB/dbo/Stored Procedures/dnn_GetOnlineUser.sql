CREATE PROCEDURE [dbo].[dnn_GetOnlineUser]
	@UserID int
AS

	SELECT
		U.UserID,
		U.UserName
	FROM dbo.dnn_Users U
	WHERE U.UserID = @UserID
		AND EXISTS (
			select 1 from dbo.dnn_UsersOnline UO where UO.UserID = U.UserID
		)

