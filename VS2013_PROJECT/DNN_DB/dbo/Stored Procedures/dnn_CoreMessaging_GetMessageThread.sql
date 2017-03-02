CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetMessageThread]
    @ConversationID int,
	@UserID int,
	@AfterMessageID int,
	@NumberOfRecords int,
	@SortField nvarchar(25) = 'CreatedOnDate',
	@SortAscending bit = 0
AS
BEGIN
	--Cannot return thread if user was not a recipient
	IF NOT EXISTS (SELECT MR.RecipientID FROM dbo.[dnn_CoreMessaging_MessageRecipients] MR JOIN dbo.[dnn_CoreMessaging_Messages] M ON MR.MessageID = M.MessageID WHERE MR.UserID = @UserID AND M.NotificationTypeID IS NULL) BEGIN
		SELECT 0
		RETURN
	END

	;WITH inboxItems  AS
	(
		SELECT  DISTINCT [RecipientID], [Subject], [Body], [SenderUserID],
				[Read], [Archived], [UserID], [To], [From], [ReplyAllAllowed], [ConversationID],
				m.[MessageID],
				m.[CreatedByUserID], m.[CreatedOnDate],
				m.[LastModifiedByUserID], m.[LastModifiedOnDate],
				(SELECT COUNT(*) FROM dbo.dnn_CoreMessaging_MessageAttachments WHERE MessageID = mr.MessageID) AS AttachmentCount,
				(SELECT COUNT(*) FROM dbo.dnn_CoreMessaging_MessageRecipients WHERE MessageID IN (SELECT MessageID FROM dbo.dnn_CoreMessaging_Messages WHERE ConversationID = m.ConversationID) AND UserID = @UserID AND [READ] = 0) AS NewThreadCount,
				(SELECT COUNT(*) FROM dbo.dnn_CoreMessaging_MessageRecipients WHERE MessageID IN (SELECT MessageID FROM dbo.dnn_CoreMessaging_Messages WHERE ConversationID = m.ConversationID) AND UserID = @UserID) AS ThreadCount,
				ROW_NUMBER() OVER(ORDER BY
					 CASE WHEN @SortField = 'CreatedOnDate' AND @SortAscending = 1 THEN m.[CreatedOnDate] END ASC,
					 CASE WHEN @SortField = 'CreatedOnDate' AND @SortAscending = 0 THEN m.[CreatedOnDate] END DESC,
					 CASE WHEN @SortField = 'From' AND @SortAscending = 1 THEN [From] END ASC,
					 CASE WHEN @SortField = 'From' AND @SortAscending = 0 THEN [From] END DESC,
					 CASE WHEN @SortField = 'Subject' AND @SortAscending = 1 THEN [Subject] END ASC,
					 CASE WHEN @SortField = 'Subject' AND @SortAscending = 0 THEN [Subject] END DESC
					) AS RowNumber
		FROM	dbo.dnn_CoreMessaging_MessageRecipients AS mr
		INNER JOIN dbo.dnn_CoreMessaging_Messages AS m ON mr.MessageID = m.MessageID
		WHERE mr.UserID = @UserID
		AND ConversationID = @ConversationID
	)
	SELECT * FROM inboxItems
	WHERE (@AfterMessageID > 0 AND RowNumber BETWEEN (SELECT RowNumber + 1 FROM inboxItems WHERE [MessageID] = @AfterMessageID) AND (SELECT RowNumber + @NumberOfRecords FROM inboxItems WHERE [MessageID] = @AfterMessageID)) OR
	(@AfterMessageID = -1 AND RowNumber BETWEEN 1 AND @NumberOfRecords)
	ORDER BY RowNumber ASC
END

