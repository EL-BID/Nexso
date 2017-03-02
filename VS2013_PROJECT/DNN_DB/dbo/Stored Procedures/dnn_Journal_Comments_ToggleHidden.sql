CREATE PROCEDURE [dbo].[dnn_Journal_Comments_ToggleHidden]
@PortalId int,
@JournalId int,
@Hidden bit
AS
UPDATE dbo.[dnn_Journal]
	SET CommentsHidden = @Hidden
	WHERE PortalId = @PortalId AND JournalId = @JournalId

