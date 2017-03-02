create procedure [dbo].[dnn_UpdateBannerClickThrough]

@BannerId int,
@VendorId int

as

update dbo.dnn_Banners
set    ClickThroughs = ClickThroughs + 1
where  BannerId = @BannerId
and    VendorId = @VendorId

