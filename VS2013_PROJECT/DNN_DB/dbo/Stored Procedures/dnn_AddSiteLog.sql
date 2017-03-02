create procedure [dbo].[dnn_AddSiteLog]

@DateTime                      datetime, 
@PortalID                      int,
@UserID                        int                   = null,
@Referrer                      nvarchar(255)         = null,
@Url                           nvarchar(255)         = null,
@UserAgent                     nvarchar(255)         = null,
@UserHostAddress               nvarchar(255)         = null,
@UserHostName                  nvarchar(255)         = null,
@TabId                         int                   = null,
@AffiliateId                   int                   = null

as
 
declare @SiteLogHistory int

insert into dbo.dnn_SiteLog ( 
  DateTime,
  PortalId,
  UserId,
  Referrer,
  Url,
  UserAgent,
  UserHostAddress,
  UserHostName,
  TabId,
  AffiliateId
)
values (
  @DateTime,
  @PortalID,
  @UserID,
  @Referrer,
  @Url,
  @UserAgent,
  @UserHostAddress,
  @UserHostName,
  @TabId,
  @AffiliateId
)

