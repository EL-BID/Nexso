CREATE PROCEDURE [dbo].[dnn_UpdatePortalAlias]
	@PortalAliasID		int,
	@PortalID 			int,
	@HTTPAlias 			nvarchar(200),
	@CultureCode		nvarchar(10),
	@Skin				nvarchar(100),
	@BrowserType		nvarchar(10),
	@IsPrimary			bit,
	@LastModifiedByUserID	int

AS

	IF @IsPrimary = 1
		BEGIN
			UPDATE dbo.dnn_PortalAlias
				SET IsPrimary = 0
				WHERE (CultureCode = @CultureCode OR (CultureCode IS NULL AND @CultureCode IS NULL))
					AND (BrowserType = @BrowserType OR (BrowserType IS NULL AND @BrowserType IS NULL))
					AND (PortalID = @PortalID)
		END

	UPDATE dbo.dnn_PortalAlias
		SET 
			HTTPAlias = @HTTPAlias,
			CultureCode = @CultureCode,
			Skin = @Skin,
			BrowserType = @BrowserType,
			IsPrimary = @IsPrimary,
			LastModifiedByUserID = @LastModifiedByUserID,
			LastModifiedOnDate = getdate()
		WHERE PortalID = @PortalID
		AND	  PortalAliasID = @PortalAliasID

