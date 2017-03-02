create procedure [dbo].[dnn_GetDatabaseVersion]

as

select Major,
       Minor,
       Build
from   dbo.dnn_Version 
where  VersionId = ( select max(VersionId) from dbo.dnn_Version )

