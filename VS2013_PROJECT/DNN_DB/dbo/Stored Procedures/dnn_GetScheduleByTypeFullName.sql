CREATE PROCEDURE [dbo].[dnn_GetScheduleByTypeFullName]
	@TypeFullName	varchar(200),
	@Server			varchar(150)
AS
    SELECT S.*
	FROM dbo.[dnn_Schedule] S
	WHERE S.TypeFullName = @TypeFullName 
		AND (@Server IS NULL OR ISNULL(s.Servers, '') = '' OR ',' + s.Servers + ',' LIKE '%,' + @Server + ',%')

