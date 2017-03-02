CREATE PROCEDURE [dbo].[dnn_DeleteUsersOnline]
	@TimeWindow int	
AS
BEGIN
    DECLARE @dt datetime
	SET @dt = DATEADD(MINUTE, -@TimeWindow, GETDATE())

	DELETE FROM dbo.dnn_AnonymousUsers WHERE LastActiveDate < @dt

	DELETE FROM dbo.dnn_UsersOnline WHERE LastActiveDate < @dt
END

