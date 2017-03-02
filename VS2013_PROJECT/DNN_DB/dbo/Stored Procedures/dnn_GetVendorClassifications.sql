CREATE PROCEDURE [dbo].[dnn_GetVendorClassifications]
    @VendorId  INT
AS
    SELECT ClassificationId,
           ClassificationName,
           CASE WHEN EXISTS ( SELECT 1 FROM dbo.dnn_VendorClassification vc WHERE vc.VendorId = @VendorId AND vc.ClassificationId = dnn_Classification.ClassificationId ) THEN 1 ELSE 0 END AS 'IsAssociated'
    FROM dbo.dnn_Classification

