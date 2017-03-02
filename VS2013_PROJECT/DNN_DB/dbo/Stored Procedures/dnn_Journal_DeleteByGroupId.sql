CREATE PROCEDURE [dbo].[dnn_Journal_DeleteByGroupId]
	@PortalId int,
	@GroupId int,
	@SoftDelete int = 0
	AS

	-- Hard Delete
	IF @SoftDelete <> 1 
	BEGIN
		DELETE dbo.[dnn_Journal_Security] 
		FROM dbo.[dnn_Journal_Security] as js  INNER JOIN dbo.[dnn_Journal] as j 
		   ON js.JournalId = j.JournalId
		WHERE j.PortalId = @PortalId AND j.GroupId = @GroupId AND @GroupId > 0 AND j.GroupId IS NOT NULL

		DELETE dbo.[dnn_Journal_Comments] 
		FROM dbo.[dnn_Journal_Comments] as jc  INNER JOIN dbo.[dnn_Journal] as j 
		   ON jc.JournalId = j.JournalId
		WHERE j.PortalId = @PortalId AND j.GroupId = @GroupId AND @GroupId > 0 AND j.GroupId IS NOT NULL

		DELETE FROM dbo.[dnn_Journal] WHERE PortalId = @PortalId AND GroupId = @GroupId AND @GroupId > 0 AND GroupId IS NOT NULL
	END

	-- Soft Delete
	IF @SoftDelete = 1 
	BEGIN
		UPDATE dbo.[dnn_Journal] SET IsDeleted = 1 WHERE PortalId = @PortalId AND GroupId = @GroupId AND @GroupId > 0 AND GroupId IS NOT NULL
	END

