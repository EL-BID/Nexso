CREATE PROCEDURE [dbo].[dnn_EnsureNeutralLanguage]
    @PortalId INT ,
    @CultureCode NVARCHAR(10)
AS 
    BEGIN
        SET NOCOUNT ON;

        UPDATE  dbo.dnn_Tabs
        SET     CultureCode = NULL
        WHERE   PortalID = @PortalId
                AND CultureCode = @CultureCode
    END

