CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetSentBox]
	@UserID INT,
	@PortalID INT,
	@AfterMessageId INT,
	@NumberOfRecords INT,
	@SortField NVARCHAR(25) = 'CreatedOnDate',
	@SortAscending BIT = 0
AS
BEGIN
	;WITH RollUpMessageIDs AS
	(
		SELECT MAX(m.MessageID) AS TopMessageID
		FROM dbo.[dnn_CoreMessaging_MessageRecipients] mr
		INNER JOIN dbo.[dnn_CoreMessaging_Messages] m ON mr.MessageID = m.MessageID AND mr.UserID = m.SenderUserID --make sure sender haven't delete the message.
		WHERE SenderUserID = @UserID AND NotificationTypeID IS NULL AND PortalID = @PortalID
		GROUP BY ConversationID
	), SentBox AS
	(
		SELECT DISTINCT m.[MessageID], [ConversationID], [Subject], CONVERT(NVARCHAR(50), [Body]) AS Body,
				[To], [From], [ReplyAllAllowed], [SenderUserID],
				m.[CreatedByUserID], m.[CreatedOnDate],
				m.[LastModifiedByUserID], m.[LastModifiedOnDate],
				(SELECT COUNT(*) FROM dbo.dnn_CoreMessaging_MessageAttachments WHERE MessageID = m.MessageID) AS AttachmentCount,
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
		FROM dbo.dnn_CoreMessaging_Messages AS m
		WHERE m.MessageID IN (SELECT TopMessageID FROM RollUpMessageIDs)
	)
	SELECT * FROM SentBox
	WHERE (@AfterMessageID > 0 AND RowNumber BETWEEN (SELECT RowNumber + 1 FROM SentBox WHERE [MessageID] = @AfterMessageID) AND (SELECT RowNumber + @NumberOfRecords FROM SentBox WHERE [MessageID] = @AfterMessageID)) OR
	(@AfterMessageID = -1 AND RowNumber BETWEEN 1 AND @NumberOfRecords)
	ORDER BY RowNumber ASC
END

