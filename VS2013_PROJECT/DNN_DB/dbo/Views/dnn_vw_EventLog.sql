CREATE VIEW [dbo].[dnn_vw_EventLog]
AS
SELECT
 el.*,
 ee.AssemblyVersion,
 ee.PortalId,
 ee.UserId,
 ee.TabId,
 ee.RawUrl,
 ee.Referrer,
 ee.UserAgent,
 e.Message,
 e.StackTrace,
 e.InnerMessage,
 e.InnerStackTrace,
 e.Source
FROM dbo.dnn_EventLog el
 LEFT JOIN dbo.dnn_ExceptionEvents ee ON el.LogEventID = ee.LogEventID
 LEFT JOIN dbo.dnn_Exceptions e ON el.ExceptionHash = e.ExceptionHash

