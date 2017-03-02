create procedure [dbo].[dnn_DeleteVendorClassifications]

@VendorId  int

as

delete
from dbo.dnn_VendorClassification
where  VendorId = @VendorId

