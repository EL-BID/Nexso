CREATE PROCEDURE [dbo].[dnn_Journal_Comment_Get]
@CommentId int
AS
SELECT jc.*, u.* FROM dbo.[dnn_Journal_Comments] as jc 
	INNER JOIN dbo.[dnn_Users] as u ON jc.UserId = u.UserId
WHERE jc.CommentId = @CommentId

