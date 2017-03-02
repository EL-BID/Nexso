create procedure [dbo].[dnn_AddProfile]

@UserID        int, 
@PortalID      int

as

insert into dbo.dnn_Profile (
  UserId,
  PortalId,
  ProfileData,
  CreatedDate
)
values (
  @UserID,
  @PortalID,
  '',
  getdate()
)

