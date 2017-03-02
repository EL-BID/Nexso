CREATE PROCEDURE [dbo].[dnn_GetEventLogConfig]
	@ID int
AS
SELECT c.*, t.LogTypeFriendlyName
FROM dbo.dnn_EventLogConfig AS c
	INNER JOIN dbo.dnn_EventLogTypes AS t ON t.LogTypeKey = c.LogTypeKey
WHERE (ID = @ID or @ID IS NULL)
ORDER BY t.LogTypeFriendlyName ASC

