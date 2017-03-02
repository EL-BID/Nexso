CREATE PROCEDURE [dbo].[dnn_AddPortalGroup]
	@PortalGroupName			nvarchar(100),
	@PortalGroupDescription		nvarchar(2000),
	@MasterPortalID				int,
	@AuthenticationDomain		nvarchar(200),
	@CreatedByUserID			int
AS 
	BEGIN
		INSERT INTO dbo.dnn_PortalGroups  
		( 
			PortalGroupName  , 
			PortalGroupDescription  ,
			MasterPortalID,
			AuthenticationDomain, 
			CreatedByUserID , 
			CreatedOnDate , 
			LastModifiedByUserID , 
			LastModifiedOnDate  
		)  
		VALUES  
		( 
			@PortalGroupName , 
			@PortalGroupDescription , 
			@MasterPortalID,
			@AuthenticationDomain, 
			@CreatedByUserID , 
			getdate() , 
			@CreatedByUserID , 
			getdate() 
		) 
		 
		SELECT SCOPE_IDENTITY()
	END

