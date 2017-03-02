create procedure [dbo].[dnn_UpdateDatabaseVersion]

@Major  int,
@Minor  int,
@Build  int

as

insert into dbo.dnn_Version (
  Major,
  Minor,
  Build,
  CreatedDate
)
values (
  @Major,
  @Minor,
  @Build,
  getdate()
)

