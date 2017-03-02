CREATE PROCEDURE [dbo].[dnn_DeletePortalGroup]
	@PortalGroupID	int
AS 
	BEGIN
		DELETE FROM dbo.dnn_PortalGroups  
			WHERE PortalGroupID = @PortalGroupID
	END

