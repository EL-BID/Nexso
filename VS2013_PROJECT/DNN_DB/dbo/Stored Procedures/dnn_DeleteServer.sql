CREATE PROCEDURE [dbo].[dnn_DeleteServer]
	@ServerID			int
AS
	DELETE FROM dbo.dnn_WebServers WHERE ServerID=@ServerID

