CREATE PROCEDURE [dbo].[dnn_GetScheduleByScheduleID]
@ScheduleID int
AS
SELECT S.*
FROM dbo.dnn_Schedule S
WHERE S.ScheduleID = @ScheduleID

