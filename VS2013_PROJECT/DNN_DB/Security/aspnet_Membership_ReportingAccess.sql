CREATE ROLE [aspnet_Membership_ReportingAccess]
    AUTHORIZATION [tcs_dba];


GO
ALTER ROLE [aspnet_Membership_ReportingAccess] ADD MEMBER [aspnet_Membership_FullAccess];

