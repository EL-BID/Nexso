CREATE PROCEDURE [dbo].[dnn_AddUser]

	@PortalID		int,
	@Username		nvarchar(100),
	@FirstName		nvarchar(50),
	@LastName		nvarchar(50),
	@AffiliateId    int,
	@IsSuperUser    bit,
	@Email          nvarchar(256),
	@DisplayName    nvarchar(100),
	@UpdatePassword	bit,
	@Authorised		bit,
	@CreatedByUserID int
AS

DECLARE @UserID int

SELECT @UserID = UserID
	FROM dbo.dnn_Users
	WHERE  Username = @Username

IF @UserID is null
	BEGIN
		INSERT INTO dbo.dnn_Users (
			Username,
			FirstName, 
			LastName, 
			AffiliateId,
			IsSuperUser,
			Email,
			DisplayName,
			UpdatePassword,
			CreatedByUserID,
			CreatedOnDate,
			LastModifiedByUserID,
			LastModifiedOnDate
		  )
		VALUES (
			@Username,
			@FirstName, 
			@LastName, 
			@AffiliateId,
			@IsSuperUser,
			@Email,
			@DisplayName,
			@UpdatePassword,
			@CreatedByUserID,
			getdate(),
			@CreatedByUserID,
			getdate()
		)

		SELECT @UserID = SCOPE_IDENTITY()
	END

	IF not exists ( SELECT 1 FROM dbo.dnn_UserPortals WHERE UserID = @UserID AND PortalID = @PortalID ) AND @PortalID > -1
		BEGIN
			INSERT INTO dbo.dnn_UserPortals (
				UserID,
				PortalID,
				Authorised,
				CreatedDate
			)
			VALUES (
				@UserID,
				@PortalID,
				@Authorised,
				getdate()
			)
		END

SELECT @UserID

