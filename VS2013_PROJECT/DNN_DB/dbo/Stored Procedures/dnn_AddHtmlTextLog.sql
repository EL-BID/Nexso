create procedure [dbo].[dnn_AddHtmlTextLog]

@ItemID          int,
@StateID         int,
@Comment         nvarchar(4000),
@Approved        bit,
@UserID          int

as

insert into dbo.dnn_HtmlTextLog (
  ItemID,
  StateID,
  Comment,
  Approved,
  CreatedByUserID,
  CreatedOnDate
)
values (
  @ItemID,
  @StateID,
  @Comment,
  @Approved,
  @UserID,
  getdate()
)

