CREATE PROCEDURE [dbo].[dnn_RemovePortalLocalization]
    @PortalId INT ,
    @CultureCode NVARCHAR(10)
AS 
    BEGIN
        SET NOCOUNT ON;

        DELETE  FROM dbo.dnn_PortalLocalization
        WHERE   PortalID = @PortalId
                AND CultureCode = @CultureCode

    END

