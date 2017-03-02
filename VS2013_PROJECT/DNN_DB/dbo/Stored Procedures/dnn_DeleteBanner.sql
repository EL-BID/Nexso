create procedure [dbo].[dnn_DeleteBanner]

@BannerId int

as

delete
from dbo.dnn_Banners
where  BannerId = @BannerId

