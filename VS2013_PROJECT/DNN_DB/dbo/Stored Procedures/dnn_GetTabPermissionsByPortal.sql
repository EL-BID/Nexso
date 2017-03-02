CREATE procedure [dbo].[dnn_GetTabPermissionsByPortal]
	
	@PortalID int

AS

	IF @portalid is not null
		BEGIN 
			SELECT *
				FROM dbo.dnn_vw_TabPermissions
				WHERE PortalID = @PortalID
		END
	ELSE
		BEGIN
			SELECT *
				FROM dbo.dnn_vw_TabPermissions
				WHERE PortalID IS NULL 
		END

