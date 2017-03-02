CREATE PROCEDURE [dbo].[dnn_UpdateAffiliateStats]
	@AffiliateId  int,
	@Clicks       int,
	@Acquisitions int
AS
	UPDATE dbo.dnn_Affiliates
		SET	Clicks = Clicks + @Clicks,
			Acquisitions = Acquisitions + @Acquisitions
		WHERE  AffiliateId = @AffiliateId 
			AND    ( StartDate < getdate() OR StartDate IS NULL ) 
			AND    ( EndDate > getdate() OR EndDate IS NULL )

