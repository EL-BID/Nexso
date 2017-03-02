CREATE PROCEDURE [dbo].[dnn_GetSchedule]
 @Server varchar(150)
AS
BEGIN
SELECT
  S.*
  , (SELECT max(S1.NextStart)
   FROM dbo.dnn_ScheduleHistory S1
   WHERE S1.ScheduleID = S.ScheduleID) as NextStart
 FROM dbo.dnn_Schedule S
 WHERE
  (@Server IS NULL OR S.Servers LIKE '%,' + @Server + ',%' OR S.Servers IS NULL)
  ORDER BY FriendlyName ASC
END

