CREATE procedure [dbo].[dnn_DeletePortalAlias]
@PortalAliasID int

as

DELETE FROM dbo.dnn_PortalAlias 
WHERE PortalAliasID = @PortalAliasID

