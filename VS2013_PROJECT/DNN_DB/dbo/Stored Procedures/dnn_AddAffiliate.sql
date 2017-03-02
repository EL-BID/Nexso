create procedure [dbo].[dnn_AddAffiliate]

@VendorId      int,
@StartDate     datetime,
@EndDate       datetime,
@CPC           float,
@CPA           float

as

insert into dbo.dnn_Affiliates (
    VendorId,
    StartDate,
    EndDate,
    CPC,
    Clicks,
    CPA,
    Acquisitions
)
values (
    @VendorId,
    @StartDate,
    @EndDate,
    @CPC,
    0,
    @CPA,
    0
)

select SCOPE_IDENTITY()

