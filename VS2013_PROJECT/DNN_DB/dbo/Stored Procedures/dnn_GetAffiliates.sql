CREATE PROCEDURE [dbo].[dnn_GetAffiliates]
    @VendorId INT
AS
    SELECT AffiliateId,
           StartDate,
           EndDate,
           CPC,
           Clicks,
           Clicks * CPC AS 'CPCTotal',
           CPA,
           Acquisitions,
           Acquisitions * CPA 'CPATotal'
    FROM   dbo.dnn_Affiliates
    WHERE  VendorId = @VendorId
    ORDER  BY StartDate DESC

