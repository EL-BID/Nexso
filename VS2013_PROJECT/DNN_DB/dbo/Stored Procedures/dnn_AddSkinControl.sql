CREATE PROCEDURE [dbo].[dnn_AddSkinControl]
	
	@PackageID					int,
	@ControlKey                 nvarchar(50),
	@ControlSrc                 nvarchar(256),
	@SupportsPartialRendering   bit,
	@CreatedByUserID	int

AS
	INSERT INTO dbo.dnn_SkinControls (
	  PackageID,
	  ControlKey,
	  ControlSrc,
      SupportsPartialRendering,
		[CreatedByUserID],
		[CreatedOnDate],
		[LastModifiedByUserID],
		[LastModifiedOnDate]
	)
	VALUES (
	  @PackageID,
	  @ControlKey,
	  @ControlSrc,
      @SupportsPartialRendering,
		@CreatedByUserID,
		getdate(),
		@CreatedByUserID,
		getdate()
	)

	SELECT SCOPE_IDENTITY()

