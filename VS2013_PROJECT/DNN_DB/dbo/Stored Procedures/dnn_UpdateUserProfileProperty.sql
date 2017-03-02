CREATE PROC [dbo].[dnn_UpdateUserProfileProperty] 

	@ProfileID				int,
	@UserID					int,
	@PropertyDefinitionID	int,
	@PropertyValue			ntext,
	@Visibility				int,
	@ExtendedVisibility		varchar(400),
	@LastUpdatedDate		datetime

AS
	IF @ProfileID IS NULL OR @ProfileID = -1
		-- Try the UserID/PropertyDefinitionID to see if the Profile property exists
		SELECT @ProfileID = ProfileID
			FROM   dbo.dnn_UserProfile
			WHERE  UserID = @UserID AND PropertyDefinitionID = @PropertyDefinitionID
	 
	IF @ProfileID IS NOT NULL
		-- Update Property
		BEGIN
			UPDATE dbo.dnn_UserProfile
				SET PropertyValue = case when (DATALENGTH(@PropertyValue) > 7500) then NULL else @PropertyValue end,
					PropertyText = case when (DATALENGTH(@PropertyValue) > 7500) then @PropertyValue else NULL end,
					Visibility = @Visibility,
					ExtendedVisibility = @ExtendedVisibility,
					LastUpdatedDate = @LastUpdatedDate
				WHERE  ProfileID = @ProfileID
			SELECT @ProfileID
		END
	ELSE
		-- Insert New Property
		BEGIN
			INSERT INTO dbo.dnn_UserProfile (
				UserID,
				PropertyDefinitionID,
				PropertyValue,
				PropertyText,
				Visibility,
				ExtendedVisibility,
				LastUpdatedDate
			  )
			VALUES (
				@UserID,
				@PropertyDefinitionID,
				case when (DATALENGTH(@PropertyValue) > 7500) then NULL else @PropertyValue end,
				case when (DATALENGTH(@PropertyValue) > 7500) then @PropertyValue else NULL end,
				@Visibility,
				@ExtendedVisibility,
				@LastUpdatedDate
			  )

		SELECT SCOPE_IDENTITY()
	END

