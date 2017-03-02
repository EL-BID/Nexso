create procedure [dbo].[dnn_UpdateProfile]

@UserID        int, 
@PortalID      int,
@ProfileData   ntext

as

update dbo.dnn_Profile
set    ProfileData = @ProfileData,
       CreatedDate = getdate()
where  UserId = @UserID
and    PortalId = @PortalID

