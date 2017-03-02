-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizations]
(
	@RowsPerPage		INT,
	@PageNumber			INT,
	@MinScore			INT, 
	@MaxScore			INT,
	@State				INT,
	@Search				varchar(500),
	@Categories			varchar(500),
	@Beneficiaries		varchar(500),
	@DeliveryFormat		varchar(500),
	@UserId				INT,
	@ChallengeReference	varchar(50),
	@SolutionType	    varchar(50),
	@Language	    varchar(50),
	@Joly				varchar(500),
	@Count int output, 
	@Organization varchar(50)
)
AS
	BEGIN
		DECLARE @filterLenght as int
		DECLARE @searchString as varchar(500)
		SET		@filterLenght=0
		SELECT	@Beneficiaries=REPLACE(@Beneficiaries,'''','')
		SELECT	@Categories=REPLACE(@Categories,'''','')
		SELECT	@DeliveryFormat=REPLACE(@DeliveryFormat,'''','')
		
		
		
		IF (LEN(@Beneficiaries)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Beneficiaries, ',')
		END

		IF (LEN(@Categories)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@Categories, ',')
		END

		IF (LEN(@DeliveryFormat)>0)
		BEGIN
			SELECT @filterLenght+=count(Data) FROM dbo.Split(@DeliveryFormat, ',')
		END



		IF (LEN(@Search)>0  )
		BEGIN
			SET @searchString=@Search
	    END
		ELSE
		BEGIN
			SET @searchString='*'
		END
		
		declare @tmpTable table(
		RowNum bigint not null,
		[SSolutionId] [uniqueidentifier] NOT NULL,
		[SSolutionTypeId] [int] NULL,
		[STitle] [varchar](200) NULL,
		[STagLine] [varchar](500) NULL,
		[SDescription] [varchar](1500) NULL,
		[SBiography] [varchar](1000) NULL,
		[SChallenge] [varchar](1000) NULL,
		[SApproach] [varchar](1000) NULL,
		[SResults] [varchar](1000) NULL,
		[SImplementationDetails] [varchar](2000) NULL,
		[SAdditionalCost] [varchar](500) NULL,
		[SAvailableResources] [varchar](500) NULL,
		[STimeFrame] [varchar](500) NULL,
		[SDuration] [int] NULL,
		[SDurationDetails] [varchar](500) NULL,
		[SSolutionStatusId] [int] NULL,
		[SSolutionType] [varchar](50) NULL,
		[STopic] [int] NULL,
		[SLanguage] [varchar](5) NULL,
		[SCreatedUserId] [int] NULL,
		[SDeleted] [bit] NULL,
		[SCountry] [nchar](50) NULL,
		[SRegion] [nchar](50) NULL,
		[SCity] [nchar](50) NULL,
		[SAddress] [varchar](200) NULL,
		[SZipCode] [varchar](50) NULL,
		[SLogo] [varchar](200) NULL,
		[SCost1] [decimal](16, 2) NULL,
		[SCost2] [decimal](16, 2) NULL,
		[SCost3] [decimal](16, 2) NULL,
		[SDeliveryFormat] [int] NULL,
		[SCost] [decimal](20, 2) NULL,
		[SCostType] [int] NULL,
		[SCostDetails] [varchar](500) NULL,
		[SSolutionState] [int] NULL,
		[SBeneficiaries] [int] NULL,
		[SDateCreated] [datetime] NULL,
		[SDateUpdated] [datetime] NULL,
		[SChallengeReference] [varchar](50) NULL,
		[SVideoObject] [varchar] (500) NULL,
		[OOrganizationID] [uniqueidentifier] NOT NULL,
		[OCode] [varchar](100) NULL,
		[OName] [varchar](100) NULL,
		[OAddress] [varchar](200) NULL,
		[OPhone] [varchar](100) NULL,
		[OEmail] [varchar](100) NULL,
		[OContactEmail] [varchar](100) NULL,
		[OWebsite] [varchar](100) NULL,
		[OTwitter] [varchar](100) NULL,
		[OSkype] [varchar](100) NULL,
		[OFacebook] [varchar](100) NULL,
		[OGooglePlus] [varchar](100) NULL,
		[OLinkedIn] [varchar](100) NULL,
		[ODescription] [varchar](800) NULL,
		[OLogo] [varchar](200) NULL,
		[OCountry] [varchar](50) NULL,
		[ORegion] [varchar](50) NULL,
		[OCity] [varchar](50) NULL,
		[OZipCode] [varchar](50) NULL,
		[OCreated] [datetime] NULL,
		[OUpdated] [datetime] NULL,
		[OLatitude] [decimal](10, 7) NULL,
		[OLongitude] [decimal](10, 7) NULL,
		[OGoogleLocation] [varchar](1000) NULL,
	    Score integer not null
		
		);
		
		
		INSERT into @tmpTable 
		
		SELECT  
							ROW_NUMBER() OVER (ORDER BY dbo.GetScore(SLN.SolutionId,'JUDGE') desc) AS RowNum,
							SLN.SolutionId AS SSolutionId, 
							SLN.SolutionTypeId AS SSolutionTypeId, 
							SLN.Title AS STitle, 
							SLN.TagLine AS STagLine,  
							SLN.Description AS SDescription, 
							SLN.Biography AS SBiography, 
							SLN.Challenge AS SChallenge, 
							SLN.Approach AS SApproach,  
							SLN.Results AS SResults, 
							SLN.ImplementationDetails AS SImplementationDetails, 
							SLN.AdditionalCost AS SAdditionalCost,  
							SLN.AvailableResources AS SAvailableResources, 
							SLN.TimeFrame AS STimeFrame, 
							SLN.Duration AS SDuration,  
							SLN.DurationDetails AS SDurationDetails, 
							SLN.SolutionStatusId AS SSolutionStatusId, 
							SLN.SolutionType AS SSolutionType,  
							SLN.Topic AS STopic, 
							SLN.Language AS SLanguage, 
							SLN.CreatedUserId AS SCreatedUserId, 
							SLN.Deleted AS SDeleted,  
							SLN.Country AS SCountry, 
							SLN.Region AS SRegion, 
							SLN.City AS SCity, 
							SLN.Address AS SAddress,  
							SLN.ZipCode AS SZipCode, 
							SLN.Logo AS SLogo, 
							SLN.Cost1 AS SCost1, 
							SLN.Cost2 AS SCost2, 
							SLN.Cost3 AS SCost3,  
							SLN.DeliveryFormat AS SDeliveryFormat, 
							SLN.Cost AS SCost, 
							SLN.CostType AS SCostType, 
							SLN.CostDetails AS SCostDetails,  
							SLN.SolutionState AS SSolutionState, 
							SLN.Beneficiaries AS SBeneficiaries, 
							SLN.DateCreated AS SDateCreated,  
							SLN.DateUpdated AS SDateUpdated, 
							SLN.ChallengeReference AS SChallengeReference, 
							SLN.VideoObject AS SVideoObject,
							ORG.OrganizationID AS OOrganizationID,  
							ORG.Code AS OCode, 
							ORG.Name AS OName, 
							ORG.Address AS OAddress, 
							ORG.Phone AS OPhone,  
							ORG.Email AS OEmail, 
							ORG.ContactEmail AS OContactEmail, 
							ORG.Website AS OWebsite, 
							ORG.Twitter AS OTwitter,  
							ORG.Skype AS OSkype, 
							ORG.Facebook AS OFacebook, 
							ORG.GooglePlus AS OGooglePlus,  
							ORG.LinkedIN AS OLinkedIn, 
							ORG.Description AS ODescription, 
							ORG.Logo AS OLogo, 
							ORG.Country AS OCountry,  
							ORG.Region AS ORegion, 
							ORG.ZipCode AS OZipCode, 
							ORG.City AS OCity,
							ORG.Created AS OCreated,  
							ORG.Updated AS OUpdated, 
							ORG.Latitude AS OLatitude, 
							ORG.Longitude AS OLongitude,  
							ORG.GoogleLocation AS OGoogleLocation,
							dbo.GetScore(SLN.SolutionId,'JUDGE') AS Score
					FROM	dbo.Solution AS SLN
							INNER JOIN dbo.Organization AS ORG ON SLN.OrganizationId = ORG.OrganizationID 
					WHERE	
					    (@Organization IS NULL OR ORG.OrganizationID = @Organization) 
					AND (@ChallengeReference='%' OR @ChallengeReference='' OR @ChallengeReference IS NULL OR SLN.ChallengeReference LIKE @ChallengeReference)
					AND (@SolutionType='%' OR @SolutionType='' OR @SolutionType IS NULL OR SLN.SolutionType LIKE @SolutionType)
					AND (@Language='%' OR @Language='' OR @Language IS NULL OR SLN.Language LIKE @Language)
							AND (@MinScore='' OR @MinScore IS NULL OR dbo.GetScore(SLN.SolutionId,'JUDGE')>= @MinScore) 
							AND (@State IS NULL OR SLN.SolutionState >= @State )
							AND (@UserId=-1 OR CreatedUserId=@UserId) 
							AND (SLN.Deleted = 0 OR SLN.Deleted IS NULL)
							AND (((@Categories = '' AND @Beneficiaries = '' AND @DeliveryFormat = '')OR(@Categories IS NULL AND @Beneficiaries IS NULL AND @DeliveryFormat IS NULL) ) OR SLN.SolutionId IN (
							
							SELECT	solutionid AS SolutionIdList 
														
	FROM	SolutionLists
	WHERE	((Category='Beneficiaries' AND [KEY] IN (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) 
or (Category='Theme' AND [KEY] IN (SELECT Data FROM dbo.Split(@Categories, ',')))
or (Category='DeliveryFormat' AND [KEY] IN (SELECT Data FROM dbo.Split(@DeliveryFormat, ','))))  
														
					
	
									
														group by solutionid
														having COUNT(solutionid)=@filterLenght
														
														))
					        AND (@searchString='*' or freetext((Title, TagLine),@searchString))
order by score	desc	
		select @Count=COUNT(*)
		from @tmpTable

		SELECT	* 
		FROM	@tmpTable AS SOD
		WHERE	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		order by score	desc	
	END
