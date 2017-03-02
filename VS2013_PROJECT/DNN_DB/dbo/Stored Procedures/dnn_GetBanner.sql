CREATE PROCEDURE [dbo].[dnn_GetBanner]
@BannerId int
as
select B.BannerId,
	   B.VendorId,
	   case when F.FileName is null then B.ImageFile else dbo.dnn_Folders.FolderPath + F.FileName end As ImageFile,
	   B.BannerName,
	   B.Impressions,
	   B.CPM,
	   B.Views,
	   B.ClickThroughs,
	   B.StartDate,
	   B.EndDate,
	   U.FirstName + ' ' + U.LastName AS CreatedByUser,
	   B.CreatedDate,
	   B.BannerTypeId,
	   B.Description,
	   B.GroupName,
	   B.Criteria,
	   B.URL,        
	   B.Width,
	   B.Height,
	   B.ImageFile AS ImageFileRaw
from   dbo.dnn_Folders INNER JOIN
       dbo.dnn_Files AS F ON dbo.dnn_Folders.FolderID = F.FolderID RIGHT OUTER JOIN
       dbo.dnn_Banners AS B INNER JOIN
       dbo.dnn_Vendors AS V ON B.VendorId = V.VendorId LEFT OUTER JOIN
       dbo.dnn_Users AS U ON B.CreatedByUser = U.UserID ON 'FileId=' + CONVERT(varchar, F.FileId) = B.ImageFile
where  B.BannerId = @BannerId

