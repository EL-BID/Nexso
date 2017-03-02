CREATE PROCEDURE [dbo].[dnn_DeleteFiles]	
    @PortalID int
AS
BEGIN
    IF @PortalID is null
    BEGIN
        DELETE FROM dbo.dnn_Files WHERE PortalId is null
    END ELSE BEGIN
        DELETE FROM dbo.dnn_Files WHERE PortalId = @PortalID
    END
END

