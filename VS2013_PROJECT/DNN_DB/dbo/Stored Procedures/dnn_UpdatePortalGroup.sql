CREATE PROCEDURE [dbo].[dnn_UpdatePortalGroup]
	@PortalGroupID				int,
	@PortalGroupName			nvarchar(100),
	@PortalGroupDescription		nvarchar(2000),
	@AuthenticationDomain		nvarchar(200),
	@LastModifiedByUserID		int
AS 
	BEGIN
		UPDATE dbo.dnn_PortalGroups 
			SET 
				PortalGroupName = @PortalGroupName,
				PortalGroupDescription = @PortalGroupDescription,
				AuthenticationDomain = @AuthenticationDomain,
				LastModifiedByUserID = @LastModifiedByUserID,
				LastModifiedOnDate = getdate()
			WHERE PortalGroupID = @PortalGroupID
	END

