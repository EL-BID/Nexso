CREATE PROCEDURE [dbo].[dnn_FindBanners]
	@PortalID     int,
	@BannerTypeId int,
	@GroupName    nvarchar(100)

AS
SELECT  B.BannerId,
		B.VendorId,
		BannerName,
		URL,
		CASE WHEN LEFT(LOWER(ImageFile), 6) = 'fileid' 
			THEN
				(SELECT Folder + FileName  
					FROM dbo.dnn_vw_Files 
					WHERE 'fileid=' + convert(varchar,dbo.dnn_vw_Files.FileID) = ImageFile
				) 
			ELSE 
				ImageFile  
			END 
		AS ImageFile,
		Impressions,
		CPM,
		B.Views,
		B.ClickThroughs,
		StartDate,
		EndDate,
		BannerTypeId,
		Description,
		GroupName,
		Criteria,
		B.Width,
		B.Height,
		B.ImageFile AS ImageFileRaw
FROM    dbo.dnn_Banners B
INNER JOIN dbo.dnn_Vendors V ON B.VendorId = V.VendorId
WHERE   (B.BannerTypeId = @BannerTypeId or @BannerTypeId is null)
AND     (B.GroupName = @GroupName or @GroupName is null)
AND     ((V.PortalId = @PortalID) or (@PortalID is null and V.PortalId is null))
AND     V.Authorized = 1 
AND     (getdate() <= B.EndDate or B.EndDate is null)
ORDER BY BannerId

