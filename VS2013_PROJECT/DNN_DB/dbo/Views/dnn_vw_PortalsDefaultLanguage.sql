CREATE VIEW [dbo].[dnn_vw_PortalsDefaultLanguage]
AS
    SELECT * FROM dbo.[dnn_vw_Portals] WHERE CultureCode = DefaultLanguage

