CREATE PROCEDURE [dbo].[dnn_Journal_Comment_Like]
		@JournalId int,
		@CommentId int,
		@UserId int,
		@UserName nvarchar(50)
	AS
	DECLARE @cxml xml
	SET @cxml = (SELECT CommentXML FROM dbo.dnn_Journal_Comments WHERE CommentId = @CommentId AND JournalId = @JournalId)
	IF @cxml IS NULL OR @cxml.exist('/root') = 0
		BEGIN
		DECLARE @x xml
			SET @x = '<root></root>';
			UPDATE dbo.dnn_Journal_Comments
				SET CommentXML = @x
				WHERE JournalId = @JournalId AND CommentId = @CommentId
		END
	IF EXISTS(SELECT CommentId
				FROM dbo.dnn_Journal_Comments
				WHERE JournalId = @JournalId AND CommentId = @CommentId
				AND CommentXML.exist('/root/likes/u[@uid=sql:variable("@userid")]') = 1)
		BEGIN
			UPDATE dbo.dnn_Journal_Comments
				SET CommentXML.modify('delete (/root/likes/u[@uid=sql:variable("@UserId")])')
				WHERE JournalId = @JournalId AND CommentId = @CommentId
				AND CommentXML.exist('/root/likes/u[@uid=sql:variable("@UserId")]') = 1
		END
	ELSE
		BEGIN
			BEGIN
				IF NOT EXISTS(SELECT CommentId FROM dbo.dnn_Journal_Comments
								WHERE JournalId = @JournalId AND CommentId = @CommentID
								AND CommentXML.exist('/root/likes') = 1)
					BEGIN
						UPDATE dbo.dnn_Journal_Comments
						SET CommentXML.modify('insert <likes /> as last into (/root)[1]') 
						WHERE JournalId = @JournalId AND CommentId = @CommentId AND CommentXML.exist('/root') = 1
					END
			END
			BEGIN
				UPDATE dbo.dnn_Journal_Comments
				SET CommentXML.modify('insert <u uid="{xs:string(sql:variable("@UserId"))}" un="{xs:string(sql:variable("@UserName"))}" /> as last into (/root/likes)[1]')
				WHERE JournalId = @JournalId AND CommentId = @CommentId AND CommentXML.exist('/root/likes') = 1
			END
		END

