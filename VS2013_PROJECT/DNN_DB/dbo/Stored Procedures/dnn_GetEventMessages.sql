CREATE PROCEDURE [dbo].[dnn_GetEventMessages]
	
	@EventName nvarchar(100)

AS
	SELECT * 
	FROM dbo.dnn_EventQueue
	WHERE EventName = @EventName
		AND IsComplete = 0
	ORDER BY SentDate

