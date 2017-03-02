CREATE PROCEDURE [dbo].[dnn_GetLanguagesByPortal]
    @PortalId			int
AS
    SELECT 
        L.*,
        PL.PortalId,
        PL.IsPublished
    FROM   dbo.dnn_Languages L
        INNER JOIN dbo.dnn_PortalLanguages PL On L.LanguageID = PL.LanguageID
    WHERE PL.PortalID = @PortalID

