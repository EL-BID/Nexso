CREATE PROCEDURE [dbo].[dnn_GetAffiliate]
	@AffiliateId int
AS

	SELECT	*
	FROM	dbo.dnn_Affiliates 
	WHERE	AffiliateId = @AffiliateId

