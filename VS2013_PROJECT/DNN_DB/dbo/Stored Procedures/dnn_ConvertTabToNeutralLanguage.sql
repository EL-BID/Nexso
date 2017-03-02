Create PROCEDURE [dbo].[dnn_ConvertTabToNeutralLanguage]
    @PortalId INT ,
    @TabId INT ,
    @CultureCode NVARCHAR(10)
AS 
    BEGIN
        SET NOCOUNT ON;

        UPDATE  dbo.dnn_Tabs
        SET     CultureCode = NULL
        WHERE   PortalID = @PortalId
                AND TabID = @TabID
                AND CultureCode = @CultureCode
    END

