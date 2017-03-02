CREATE PROCEDURE [dbo].[dnn_DeleteEventLog]	
    @LogGUID varchar(36)
AS
BEGIN
    IF @LogGUID is null
    BEGIN
        DELETE FROM dbo.dnn_EventLog
    END ELSE BEGIN
        DELETE FROM dbo.dnn_EventLog WHERE LogGUID = @LogGUID
    END
END

