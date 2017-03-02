CREATE PROCEDURE [dbo].[dnn_GetPortalDefaultLanguage]

	@PortalId            int

AS
	SELECT defaultlanguage
		FROM dbo.dnn_Portals
		where portalid=@PortalId

