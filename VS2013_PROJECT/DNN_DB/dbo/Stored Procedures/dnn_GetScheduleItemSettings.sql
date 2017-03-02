CREATE PROCEDURE [dbo].[dnn_GetScheduleItemSettings] 
@ScheduleID int
AS
SELECT *
FROM dbo.dnn_ScheduleItemSettings
WHERE ScheduleID = @ScheduleID

