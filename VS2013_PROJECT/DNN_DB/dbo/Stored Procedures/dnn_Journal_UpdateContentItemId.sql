CREATE PROCEDURE [dbo].[dnn_Journal_UpdateContentItemId]
@JournalId int,
@ContentItemId int
AS
UPDATE dbo.[dnn_Journal]
	SET ContentItemId = @ContentItemId
WHERE JournalId = @JournalId

