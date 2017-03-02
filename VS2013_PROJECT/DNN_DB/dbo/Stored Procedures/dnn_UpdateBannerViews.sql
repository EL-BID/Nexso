create procedure [dbo].[dnn_UpdateBannerViews]

@BannerId  int, 
@StartDate datetime, 
@EndDate   datetime

as

update dbo.dnn_Banners
set    Views = Views + 1,
       StartDate = @StartDate,
       EndDate = @EndDate
where  BannerId = @BannerId

