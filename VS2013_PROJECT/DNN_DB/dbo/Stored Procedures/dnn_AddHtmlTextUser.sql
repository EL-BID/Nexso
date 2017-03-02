create procedure [dbo].[dnn_AddHtmlTextUser]

@ItemID          int,
@StateID         int,
@ModuleID        int,
@TabID           int,
@UserID          int

as

insert into dbo.dnn_HtmlTextUsers (
  ItemID,
  StateID,
  ModuleID,
  TabID,
  UserID,
  CreatedOnDate
)
values (
  @ItemID,
  @StateID,
  @ModuleID,
  @TabID,
  @UserID,
  getdate()
)

