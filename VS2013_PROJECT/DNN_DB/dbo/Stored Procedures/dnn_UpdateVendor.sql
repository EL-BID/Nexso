CREATE procedure [dbo].[dnn_UpdateVendor]

@VendorId	int,
@VendorName nvarchar(50),
@Unit	 	nvarchar(50),
@Street 	nvarchar(50),
@City		nvarchar(50),
@Region	    nvarchar(50),
@Country	nvarchar(50),
@PostalCode	nvarchar(50),
@Telephone	nvarchar(50),
@Fax		nvarchar(50),
@Cell		nvarchar(50),
@Email		nvarchar(50),
@Website	nvarchar(100),
@FirstName	nvarchar(50),
@LastName	nvarchar(50),
@UserName   nvarchar(100),
@LogoFile   nvarchar(100),
@KeyWords   text,
@Authorized bit

as

update dbo.dnn_Vendors
set    VendorName    = @VendorName,
       Unit          = @Unit,
       Street        = @Street,
       City          = @City,
       Region        = @Region,
       Country       = @Country,
       PostalCode    = @PostalCode,
       Telephone     = @Telephone,
       Fax           = @Fax,
       Cell          = @Cell,
       Email         = @Email,
       Website       = @Website,
       FirstName     = @FirstName,
       LastName      = @LastName,
       CreatedByUser = @UserName,
       CreatedDate   = getdate(),
       LogoFile      = @LogoFile,
       KeyWords      = @KeyWords,
       Authorized    = @Authorized
where  VendorId = @VendorId

