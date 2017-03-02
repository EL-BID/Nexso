create procedure [dbo].[dnn_AddHtmlText]

@ModuleID        int,
@Content         ntext,
@Summary	     ntext,
@StateID         int,
@IsPublished     bit,
@UserID          int,
@History         int

as

declare @Version int

select @Version = max(Version) from dbo.dnn_HtmlText where ModuleID = @ModuleID

if @Version is null
  select @Version = 1
else
  select @Version = @Version + 1

insert into dbo.dnn_HtmlText (
  ModuleID,
  Content,
  Summary,
  Version,
  StateID,
  IsPublished,
  CreatedByUserID,
  CreatedOnDate,
  LastModifiedByUserID,
  LastModifiedOnDate
) 
values (
  @ModuleID,
  @Content,
  @Summary,
  @Version,
  @StateID,
  @IsPublished,
  @UserID,
  getdate(),
  @UserID,
  getdate()
)

if @History > 0
begin
  delete
  from   dbo.dnn_HtmlText
  where  ModuleID = @ModuleID
  and    Version <= (@Version - @History)
end

select SCOPE_IDENTITY()

