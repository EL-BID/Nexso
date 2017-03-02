CREATE PROCEDURE [dbo].[dnn_AddUserAuthentication]
	@UserID					int,
	@AuthenticationType     nvarchar(100),
	@AuthenticationToken    nvarchar(1000),
	@CreatedByUserID	int

AS
	INSERT INTO dbo.dnn_UserAuthentication (
		UserID,
		AuthenticationType,
		AuthenticationToken,
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]

	)
	values (
		@UserID,
		@AuthenticationType,
		@AuthenticationToken,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()

	)

	SELECT SCOPE_IDENTITY()

