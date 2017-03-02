create procedure [dbo].[dnn_UpdateBanner]

@BannerId     int,
@BannerName   nvarchar(100),
@ImageFile    nvarchar(100),
@URL          nvarchar(255),
@Impressions  int,
@CPM          float,
@StartDate    datetime,
@EndDate      datetime,
@UserName     nvarchar(100),
@BannerTypeId int,
@Description  nvarchar(2000),
@GroupName    nvarchar(100),
@Criteria     bit,
@Width        int,
@Height       int

as

update dbo.dnn_Banners
set    ImageFile     = @ImageFile,
       BannerName    = @BannerName,
       URL           = @URL,
       Impressions   = @Impressions,
       CPM           = @CPM,
       StartDate     = @StartDate,
       EndDate       = @EndDate,
       CreatedByUser = @UserName,
       CreatedDate   = getdate(),
       BannerTypeId  = @BannerTypeId,
       Description   = @Description,
       GroupName     = @GroupName,
       Criteria      = @Criteria,
       Width         = @Width,
       Height        = @Height
where  BannerId = @BannerId

