create procedure [dbo].[dnn_UpdateAffiliate]

@AffiliateId int,
@StartDate         datetime,
@EndDate           datetime,
@CPC               float,
@CPA               float

as

update dbo.dnn_Affiliates
set    StartDate   = @StartDate,
       EndDate     = @EndDate,
       CPC         = @CPC,
       CPA         = @CPA
where  AffiliateId = @AffiliateId

