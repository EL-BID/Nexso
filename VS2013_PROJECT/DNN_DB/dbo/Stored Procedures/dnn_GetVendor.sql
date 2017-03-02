CREATE procedure [dbo].[dnn_GetVendor]

@VendorId int,
@PortalId int

as

select dbo.dnn_Vendors.VendorName, 
       dbo.dnn_Vendors.Unit, 
       dbo.dnn_Vendors.Street, 
       dbo.dnn_Vendors.City, 
       dbo.dnn_Vendors.Region, 
       dbo.dnn_Vendors.Country, 
       dbo.dnn_Vendors.PostalCode, 
       dbo.dnn_Vendors.Telephone,
       dbo.dnn_Vendors.Fax,
       dbo.dnn_Vendors.Cell,
       dbo.dnn_Vendors.Email,
       dbo.dnn_Vendors.Website,
       dbo.dnn_Vendors.FirstName,
       dbo.dnn_Vendors.LastName,
       dbo.dnn_Vendors.ClickThroughs,
       dbo.dnn_Vendors.Views,
       dbo.dnn_Users.FirstName + ' ' + dbo.dnn_Users.LastName As CreatedByUser,
       dnn_Vendors.CreatedDate,
       case when dbo.dnn_Files.FileName is null then dbo.dnn_Vendors.LogoFile else dnn_Folders.FolderPath + dnn_Files.FileName end as LogoFile,
       dbo.dnn_Vendors.KeyWords,
       dbo.dnn_Vendors.Authorized,
       dbo.dnn_Vendors.PortalId
from dbo.dnn_Folders 
INNER JOIN dbo.dnn_Files ON dbo.dnn_Folders.FolderID = dbo.dnn_Files.FolderID RIGHT OUTER JOIN
dbo.dnn_Vendors LEFT OUTER JOIN
dbo.dnn_Users ON dbo.dnn_Vendors.CreatedByUser = dbo.dnn_Users.UserID ON 'fileid=' + CONVERT(varchar, dbo.dnn_Files.FileId) = dbo.dnn_Vendors.LogoFile
where  VendorId = @VendorId
and    ((dnn_Vendors.PortalId = @PortalId) or (dnn_Vendors.PortalId is null and @PortalId is null))

