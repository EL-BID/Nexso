CREATE PROCEDURE [dbo].[dnn_GetScheduleNextTask]
	@Server varchar(150)
AS
SELECT TOP 1
        S.[ScheduleID] ,
        S.[TypeFullName] ,
        S.[TimeLapse] ,
        S.[TimeLapseMeasurement] ,
        S.[RetryTimeLapse] ,
        S.[RetryTimeLapseMeasurement] ,
        S.[RetainHistoryNum] ,
        S.[AttachToEvent] ,
        S.[CatchUpEnabled] ,
        S.[Enabled] ,
        S.[ObjectDependencies] ,
        S.[Servers] ,
        S.[CreatedByUserID] ,
        S.[CreatedOnDate] ,
        S.[LastModifiedByUserID] ,
        S.[LastModifiedOnDate] ,
        S.[FriendlyName] ,
        H.[NextStart]
FROM    dbo.[dnn_Schedule] S
        CROSS APPLY ( SELECT TOP 1
                                [NextStart]
                      FROM      dbo.[dnn_ScheduleHistory]
                      WHERE     ( [ScheduleID] = S.[ScheduleID] )
                      ORDER BY  [NextStart] DESC
                    ) AS H ( [NextStart] )
WHERE   ( S.[Enabled] = 1 )
        AND ( ( S.[Servers] LIKE ( ',%' + @Server + '%,' ) )
              OR ( S.[Servers] IS NULL )
            )
ORDER BY H.[NextStart] ASC

