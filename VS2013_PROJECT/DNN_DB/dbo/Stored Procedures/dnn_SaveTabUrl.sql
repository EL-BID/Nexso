CREATE PROCEDURE [dbo].[dnn_SaveTabUrl] 
	@TabID				int,
	@SeqNum				int,
	@PortalAliasID		int,
	@PortalAliasUsage	int,
	@Url				nvarchar(200),
	@QueryString		nvarchar(200),
	@CultureCode		nvarchar(50),
	@HttpStatus			nvarchar(50),
	@IsSystem			bit,
	@ModifiedByUserID	int
AS
	IF @HttpStatus = '200'
		BEGIN
			UPDATE dbo.dnn_TabUrls
				SET HttpStatus = '301',
				[LastModifiedByUserID]= @ModifiedByUserID,
				[LastModifiedOnDate]= getdate()
				WHERE TabID = @TabID
					AND CultureCode = @CultureCode
					AND (@PortalAliasID = @PortalAliasID OR (PortalAliasId IS NULL AND @PortalAliasID IS NULL))
					AND HttpStatus = '200'
		END  
	IF EXISTS (SELECT * FROM dbo.dnn_TabUrls WHERE TabId = @TabID AND SeqNum = @SeqNum)
		BEGIN
			UPDATE dbo.dnn_TabUrls
				SET 
					PortalAliasId = @PortalAliasID,
					PortalAliasUsage = @PortalAliasUsage,
					Url = @Url,
					QueryString = @QueryString,
					CultureCode = @CultureCode,
					HttpStatus = @HttpStatus,
					IsSystem = @IsSystem,
					[LastModifiedByUserID]= @ModifiedByUserID,
					[LastModifiedOnDate]= getdate()
			WHERE TabId = @TabID AND SeqNum = @SeqNum 
		END
	ELSE
		BEGIN
			INSERT INTO dbo.dnn_TabUrls
					( TabId ,
					  SeqNum ,
					  Url ,
					  QueryString ,
					  HttpStatus ,
					  CultureCode ,
					  IsSystem,
					  PortalAliasId ,
					  PortalAliasUsage,
					  [CreatedByUserID],
					  [CreatedOnDate],
				  	  [LastModifiedByUserID],
					  [LastModifiedOnDate]
					)
			VALUES  ( @TabID ,
					  @SeqNum ,
					  @Url ,
					  @QueryString ,
					  @HttpStatus ,
					  @CultureCode ,
					  @IsSystem,
					  @PortalAliasID ,
					  0,
					  @ModifiedByUserID,
					  getdate(),
					  @ModifiedByUserID,
					  getdate()
					)
		END

