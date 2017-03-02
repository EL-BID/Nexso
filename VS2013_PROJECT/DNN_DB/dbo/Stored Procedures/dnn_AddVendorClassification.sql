create procedure [dbo].[dnn_AddVendorClassification]

@VendorId           int,
@ClassificationId   int

as

insert into dbo.dnn_VendorClassification ( 
  VendorId,
  ClassificationId
)
values (
  @VendorId,
  @ClassificationId
)

select SCOPE_IDENTITY()

