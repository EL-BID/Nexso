CREATE PROCEDURE [dbo].[dnn_CoreMessaging_GetNextMessagesForInstantDispatch]
	@SchedulerInstance UNIQUEIDENTIFIER ,
	@BatchSize INT
AS 
	BEGIN
		UPDATE  dbo.[dnn_CoreMessaging_MessageRecipients]
		SET     EmailSchedulerInstance = @SchedulerInstance
		WHERE   RecipientID IN (
				SELECT TOP ( @BatchSize )
						RecipientID 
				FROM    dbo.[dnn_vw_MessagesForDispatch] MFD
				WHERE   EmailSent = 0
						AND [Read] = 0
						AND Archived = 0
						AND EmailFrequency = 0
						AND ( ( EmailSchedulerInstance IS NULL
								AND EmailSentDate IS NULL
							  )
							  OR EmailSchedulerInstance = '00000000-0000-0000-0000-000000000000'
							)
				ORDER BY MFD.CreatedOnDate DESC ,
						UserID )

		SELECT  *
		FROM    dbo.[dnn_CoreMessaging_MessageRecipients] CMR
				INNER JOIN dbo.[dnn_CoreMessaging_Messages] CMM ON CMR.MessageID = CMM.MessageID
		WHERE   EmailSent = 0
				AND EmailSentDate IS NULL
				AND [Read] = 0
				AND Archived = 0
				AND ( EmailSchedulerInstance = @SchedulerInstance )
		ORDER BY UserID ,
				CMM.CreatedOnDate DESC	
	END

