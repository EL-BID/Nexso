CREATE PROCEDURE [dbo].[dnn_GetBannerGroups]
	@PortalID int
AS

SELECT  GroupName
FROM dbo.dnn_Banners
INNER JOIN dbo.dnn_Vendors ON 
	dbo.dnn_Banners.VendorId = dbo.dnn_Vendors.VendorId
WHERE (dbo.dnn_Vendors.PortalId = @PortalID) OR 
	(@PortalID is null and dbo.dnn_Vendors.PortalId is null)
GROUP BY GroupName
ORDER BY GroupName

