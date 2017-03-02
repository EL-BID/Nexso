create procedure [dbo].[dnn_AddBanner]

@BannerName    nvarchar(100),
@VendorId      int,
@ImageFile     nvarchar(100),
@URL           nvarchar(255),
@Impressions   int,
@CPM           float,
@StartDate     datetime,
@EndDate       datetime,
@UserName      nvarchar(100),
@BannerTypeId  int,
@Description   nvarchar(2000),
@GroupName     nvarchar(100),
@Criteria      bit,
@Width         int,
@Height        int

as

insert into dbo.dnn_Banners (
    VendorId,
    ImageFile,
    BannerName,
    URL,
    Impressions,
    CPM,
    Views,
    ClickThroughs,
    StartDate,
    EndDate,
    CreatedByUser,
    CreatedDate,
    BannerTypeId,
    Description,
    GroupName,
    Criteria,
    Width,
    Height
)
values (
    @VendorId,
    @ImageFile,
    @BannerName,
    @URL,
    @Impressions,
    @CPM,
    0,
    0,
    @StartDate,
    @EndDate,
    @UserName,
    getdate(),
    @BannerTypeId,
    @Description,
    @GroupName,
    @Criteria,
    @Width,
    @Height
)

select SCOPE_IDENTITY()

