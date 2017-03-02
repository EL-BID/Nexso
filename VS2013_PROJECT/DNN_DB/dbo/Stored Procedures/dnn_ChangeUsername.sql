CREATE PROCEDURE [dbo].[dnn_ChangeUsername]
	@UserId         int,
	@NewUsername	nvarchar(256)
AS
BEGIN
	DECLARE @OldUsername NVARCHAR(256)
	SET @OldUsername = (SELECT UserName FROM dbo.dnn_Users WHERE UserId = @UserId)

	UPDATE dbo.dnn_Users
		SET		Username=@NewUsername
		WHERE	UserId=@UserId

	UPDATE dbo.aspnet_Users
		SET		UserName=@NewUsername,
				LoweredUserName=LOWER(@NewUsername) 
		WHERE	UserName=@OldUsername

END

