CREATE PROCEDURE [dbo].[dnn_GetEventMessagesBySubscriber]
	
	@EventName nvarchar(100),
	@Subscriber nvarchar(100)

AS
	SELECT * 
	FROM dbo.dnn_EventQueue
	WHERE EventName = @EventName
		AND Subscriber = @Subscriber
		AND IsComplete = 0
	ORDER BY SentDate

