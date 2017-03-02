CREATE PROCEDURE [dbo].[dnn_LocalizeTab] 
	@TabId					int,
	@CultureCode			nvarchar(10),
	@LastModifiedByUserID	int
AS
	BEGIN
		UPDATE dbo.dnn_Tabs
			SET 
				CultureCode				= @CultureCode,
				LastModifiedByUserID	= @LastModifiedByUserID,
				LastModifiedOnDate		= getdate()					
			WHERE TabID = @TabId
			
		UPDATE dbo.dnn_TabModules
			SET 
				CultureCode				= @CultureCode,
				LastModifiedByUserID	= @LastModifiedByUserID,
				LastModifiedOnDate		= getdate()					
			WHERE TabID = @TabId
	END

