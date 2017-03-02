CREATE PROCEDURE [dbo].[dnn_UpdatePortalDefaultLanguage]

	@PortalId            int,
	@CultureCode   nvarchar(50)
AS
	UPDATE dbo.dnn_Portals
		SET defaultlanguage=@CultureCode
		where portalid=@PortalId

