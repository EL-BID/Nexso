CREATE PROCEDURE [dbo].[dnn_Journal_Comments_ToggleDisable]
@PortalId int,
@JournalId int,
@Disabled bit
AS
UPDATE dbo.[dnn_Journal]
	SET CommentsDisabled = @Disabled
	WHERE PortalId = @PortalId AND JournalId = @JournalId

