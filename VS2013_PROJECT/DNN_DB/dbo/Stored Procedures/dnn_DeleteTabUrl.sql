CREATE PROCEDURE [dbo].[dnn_DeleteTabUrl] 
	@TabID				int,
	@SeqNum				int
AS
	DELETE FROM dbo.dnn_TabUrls
	WHERE TabId = @TabID AND SeqNum = @SeqNum

