CREATE ROLE [aspnet_Membership_BasicAccess]
    AUTHORIZATION [tcs_dba];


GO
ALTER ROLE [aspnet_Membership_BasicAccess] ADD MEMBER [aspnet_Membership_FullAccess];

