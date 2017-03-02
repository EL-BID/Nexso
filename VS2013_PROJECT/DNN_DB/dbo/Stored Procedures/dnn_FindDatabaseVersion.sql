create procedure [dbo].[dnn_FindDatabaseVersion]

@Major  int,
@Minor  int,
@Build  int

as

select 1
from   dbo.dnn_Version
where  Major = @Major
and    Minor = @Minor
and    Build = @Build

