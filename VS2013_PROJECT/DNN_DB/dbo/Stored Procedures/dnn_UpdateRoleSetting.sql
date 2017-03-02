CREATE PROCEDURE [dbo].[dnn_UpdateRoleSetting]
	@RoleID				int,
	@SettingName		nvarchar(50),
	@SettingValue		nvarchar(2000),
	@UserID				int

AS
	IF (SELECT COUNT(*) FROM dbo.dnn_RoleSettings WHERE RoleID = @RoleID AND SettingName = @SettingName) > 0
		--Update
		UPDATE  dbo.dnn_RoleSettings
			SET SettingValue = @SettingValue,
				[LastModifiedByUserID]=@UserID,
				[LastModifiedOnDate]=getdate()
		WHERE RoleID = @RoleID
			AND SettingName = @SettingName
			
	ELSE
		--Add
		INSERT INTO dbo.dnn_RoleSettings 
		( 
			RoleID, 
			SettingName, 
			SettingValue, 
			CreatedByUserID, 
			CreatedOnDate, 
			LastModifiedByUserID, 
			LastModifiedOnDate
		) 
		VALUES 
		( 
			@RoleID, 
			@SettingName,
			@SettingValue ,
			@UserID ,
			getdate() ,
			@UserID,
			getdate()
		)

