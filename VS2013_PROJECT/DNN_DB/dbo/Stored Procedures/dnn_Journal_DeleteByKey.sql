CREATE PROCEDURE [dbo].[dnn_Journal_DeleteByKey]
	@PortalId int,
	@ObjectKey nvarchar(255),
	@SoftDelete int = 0
	AS
	DECLARE @JournalId int
	SET @JournalId = (SELECT JournalId FROM dbo.[dnn_Journal] WHERE PortalId = @PortalId AND ObjectKey = @ObjectKey AND @ObjectKey <> '' AND ObjectKey IS NOT NULL)

	-- Hard Delete
	IF @JournalId > 0 AND @SoftDelete <> 1 
	BEGIN
		DELETE FROM dbo.[dnn_Journal_Security] WHERE JournalId = @JournalId
		DELETE FROM dbo.[dnn_Journal_Comments] WHERE JournalId = @JournalId
		DELETE FROM dbo.[dnn_Journal] WHERE JournalId = @JournalId
	END

	-- Soft Delete
	IF @JournalId > 0 AND @SoftDelete = 1 
	BEGIN
		UPDATE dbo.[dnn_Journal] SET IsDeleted = 1 WHERE JournalId = @JournalId
	END

