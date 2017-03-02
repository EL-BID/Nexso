CREATE PROCEDURE [dbo].[dnn_Messaging_GetNextMessageForDispatch] 
	@SchedulerInstance uniqueidentifier
AS
	Declare  @target_messageID int

	SELECT @target_messageID =  MessageID FROM dnn_Messaging_Messages WHERE EmailSent = 0  AND  
	(EmailSchedulerInstance is NULL or EmailSchedulerInstance= '00000000-0000-0000-0000-000000000000') 
	AND status not in  (0,3) ORDER BY Date DESC

Update dnn_Messaging_Messages set EmailSchedulerInstance = @SchedulerInstance  where MessageID = @target_messageID
select * from dnn_Messaging_Messages where MessageID = @target_messageID

