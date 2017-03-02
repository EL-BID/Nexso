create procedure [dbo].[dnn_AddUrl]

@PortalID     int,
@Url          nvarchar(255)

as

insert into dbo.dnn_Urls (
  PortalID,
  Url
)
values (
  @PortalID,
  @Url
)

