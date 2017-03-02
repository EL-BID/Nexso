CREATE PROCEDURE [dbo].[dnn_UpdateUserRole]
    @UserRoleId		int, 
	@Status			int,
	@IsOwner		bit,
	@EffectiveDate	datetime = null,
	@ExpiryDate		datetime = null,
	@LastModifiedByUserID			int
AS
	UPDATE dbo.dnn_UserRoles 
		SET 
			Status = @Status,
			IsOwner = @IsOwner,
			ExpiryDate = @ExpiryDate,
			EffectiveDate = @EffectiveDate,
			IsTrialUsed = 1,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate()
		WHERE  UserRoleId = @UserRoleId

