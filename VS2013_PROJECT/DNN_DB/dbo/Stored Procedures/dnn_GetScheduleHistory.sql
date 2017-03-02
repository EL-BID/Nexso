CREATE PROCEDURE [dbo].[dnn_GetScheduleHistory] @ScheduleID INT
AS 
    SELECT  S.* ,
            SH.*
    FROM    dbo.dnn_Schedule S
            INNER JOIN dbo.dnn_ScheduleHistory SH ON S.ScheduleID = SH.ScheduleID
    WHERE   S.ScheduleID = @ScheduleID
            OR @ScheduleID = -1
    ORDER BY SH.StartDate DESC

