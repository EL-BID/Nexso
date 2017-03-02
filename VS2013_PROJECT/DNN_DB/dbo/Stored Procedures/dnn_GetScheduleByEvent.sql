CREATE PROCEDURE [dbo].[dnn_GetScheduleByEvent]
	@EventName	varchar(50),
	@Server		varchar(150)
AS
    SELECT S.*
	FROM dbo.[dnn_Schedule] S
	WHERE S.AttachToEvent = @EventName
		AND (@Server IS NULL OR ISNULL(s.Servers, '') = '' OR ',' + s.Servers + ',' LIKE '%,' + @Server + ',%')

