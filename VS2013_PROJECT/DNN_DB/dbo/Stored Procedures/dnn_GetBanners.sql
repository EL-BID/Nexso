create procedure [dbo].[dnn_GetBanners]

@VendorId int

as

select BannerId,
       BannerName,
       URL,
       Impressions,
       CPM,
       Views,
       ClickThroughs,
       StartDate,
       EndDate,
       BannerTypeId,
       Description,
       GroupName,
       Criteria,
       Width,
       Height
from   dbo.dnn_Banners
where  VendorId = @VendorId
order  by CreatedDate desc

