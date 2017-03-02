create procedure [dbo].[dnn_DeleteAffiliate]

@AffiliateId int

as

delete
from   dbo.dnn_Affiliates
where  AffiliateId = @AffiliateId

