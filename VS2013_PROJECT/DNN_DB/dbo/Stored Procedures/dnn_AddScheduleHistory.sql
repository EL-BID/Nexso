CREATE PROCEDURE [dbo].[dnn_AddScheduleHistory]
@ScheduleID int,
@StartDate datetime,
@Server varchar(150)
AS
INSERT INTO dbo.dnn_ScheduleHistory
(ScheduleID,
StartDate,
Server)
VALUES
(@ScheduleID,
@StartDate,
@Server)

select SCOPE_IDENTITY()

