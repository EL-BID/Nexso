CREATE PROCEDURE [dbo].[dnn_GetPackages]
	@PortalID	int
AS
	SELECT *
		FROM   dbo.dnn_Packages
		WHERE (PortalID = @PortalID OR @PortalID IS NULL OR PortalID IS NULL)
		ORDER BY PackageType ASC, [FriendlyName] ASC

