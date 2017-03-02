CREATE PROCEDURE [dbo].[dnn_PurgeEventLog]

AS
	;WITH logcounts AS
	(  
	  SELECT 
		LogEventID, 
		LogConfigID, 
		ROW_NUMBER() OVER(PARTITION BY LogConfigID ORDER BY LogCreateDate DESC) AS logEventSequence
	  FROM dbo.dnn_EventLog
	)
	DELETE dbo.dnn_EventLog 
	FROM dbo.dnn_EventLog el 
		JOIN logcounts lc ON el.LogEventID = lc.LogEventID
		INNER JOIN dbo.dnn_EventLogConfig elc ON elc.ID = lc.LogConfigID
	WHERE elc.KeepMostRecent <> -1
		AND lc.logEventSequence > elc.KeepMostRecent

