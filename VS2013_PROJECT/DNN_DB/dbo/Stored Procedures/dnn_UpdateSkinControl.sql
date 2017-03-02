CREATE PROCEDURE [dbo].[dnn_UpdateSkinControl]
	
	@SkinControlID					int,
	@PackageID						int,
	@ControlKey						nvarchar(50),
	@ControlSrc						nvarchar(256),
	@SupportsPartialRendering		bit,
	@LastModifiedByUserID	int

AS
	UPDATE dbo.dnn_SkinControls
	SET    
		PackageID = @PackageID,
		ControlKey = @ControlKey,
		ControlSrc = @ControlSrc,
		SupportsPartialRendering = @SupportsPartialRendering,
 		[LastModifiedByUserID] = @LastModifiedByUserID,	
		[LastModifiedOnDate] = getdate()
	WHERE  SkinControlID = @SkinControlID

