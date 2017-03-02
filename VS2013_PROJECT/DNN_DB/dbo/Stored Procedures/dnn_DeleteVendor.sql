create procedure [dbo].[dnn_DeleteVendor]

@VendorId int

as

delete
from dbo.dnn_Vendors
where  VendorId = @VendorId

