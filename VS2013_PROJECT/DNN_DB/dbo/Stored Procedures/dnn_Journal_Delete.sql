CREATE PROCEDURE [dbo].[dnn_Journal_Delete]
	@JournalId int,
	@SoftDelete int = 0
	AS

	-- Hard Delete
	IF @SoftDelete <> 1 
	BEGIN
		DELETE FROM dbo.[dnn_Journal_Security] WHERE JournalId = @JournalId
		DELETE FROM dbo.[dnn_Journal_Comments] WHERE JournalId = @JournalId
		DELETE FROM dbo.[dnn_Journal] WHERE JournalId = @JournalId
	END

	-- Soft Delete
	IF @SoftDelete = 1 
	BEGIN
		UPDATE dbo.[dnn_Journal] SET IsDeleted = 1 WHERE JournalId = @JournalId
	END

