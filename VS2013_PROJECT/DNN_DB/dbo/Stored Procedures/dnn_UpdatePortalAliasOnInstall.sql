CREATE PROCEDURE [dbo].[dnn_UpdatePortalAliasOnInstall]
	@PortalAlias			nvarchar(200),
	@LastModifiedByUserID	int
AS
	UPDATE dbo.dnn_PortalAlias 
		SET HTTPAlias = @PortalAlias,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate()
	WHERE  HTTPAlias = '_default'

