create procedure [dbo].[dnn_AddUrlLog]

@UrlTrackingID int,
@UserID        int

as

insert into dbo.dnn_UrlLog (
  UrlTrackingID,
  ClickDate,
  UserID
)
values (
  @UrlTrackingID,
  getdate(),
  @UserID
)

