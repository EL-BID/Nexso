CREATE PROCEDURE [dbo].[dnn_Journal_Comment_Delete]
@JournalId int,
@CommentId int
AS
DELETE FROM dbo.[dnn_Journal_Comments] 
	WHERE 
		(JournalId = @JournalId AND CommentId = @CommentId)
		OR
		(JournalId = @JournalId AND CommentId = -1)

