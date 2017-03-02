CREATE procedure [dbo].[dnn_AddVendor]

@PortalID 	int,
@VendorName nvarchar(50),
@Unit    	nvarchar(50),
@Street 	nvarchar(50),
@City		nvarchar(50),
@Region	    nvarchar(50),
@Country	nvarchar(50),
@PostalCode	nvarchar(50),
@Telephone	nvarchar(50),
@Fax   	    nvarchar(50),
@Cell   	nvarchar(50),
@Email    	nvarchar(50),
@Website	nvarchar(100),
@FirstName	nvarchar(50),
@LastName	nvarchar(50),
@UserName   nvarchar(100),
@LogoFile   nvarchar(100),
@KeyWords   text,
@Authorized bit

as

insert into dbo.dnn_Vendors (
  VendorName,
  Unit,
  Street,
  City,
  Region,
  Country,
  PostalCode,
  Telephone,
  PortalId,
  Fax,
  Cell,
  Email,
  Website,
  FirstName,
  Lastname,
  ClickThroughs,
  Views,
  CreatedByUser,
  CreatedDate,
  LogoFile,
  KeyWords,
  Authorized
)
values (
  @VendorName,
  @Unit,
  @Street,
  @City,
  @Region,
  @Country,
  @PostalCode,
  @Telephone,
  @PortalID,
  @Fax,
  @Cell,
  @Email,
  @Website,
  @FirstName,
  @LastName,
  0,
  0,
  @UserName,
  getdate(), 
  @LogoFile,
  @KeyWords,
  @Authorized
)

select SCOPE_IDENTITY()

