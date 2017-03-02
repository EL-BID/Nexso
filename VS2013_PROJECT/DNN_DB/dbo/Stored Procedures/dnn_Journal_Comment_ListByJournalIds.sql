CREATE PROCEDURE [dbo].[dnn_Journal_Comment_ListByJournalIds]
@JounalIds nvarchar(max) = ''
AS
SELECT jc.*, u.* FROM dbo.[dnn_Journal_Comments] as jc 
	INNER JOIN dbo.[dnn_Users] as u ON jc.UserId = u.UserId
	INNER JOIN dbo.[dnn_Journal_Split](@JounalIds,';') as j ON j.id = jc.JournalId
ORDER BY jc.CommentId ASC

