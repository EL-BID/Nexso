CREATE PROCEDURE [dbo].[dnn_Journal_Comment_List]
@JournalId int
AS
SELECT jc.*, u.* FROM dbo.[dnn_Journal_Comments] as jc 
	INNER JOIN dbo.[dnn_Users] as u ON jc.UserId = u.UserId
WHERE jc.JournalId = @JournalId
ORDER BY jc.CommentId

