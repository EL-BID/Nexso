-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizationsV2]
(
	@RowsPerPage		INT,
	@PageNumber			INT,
	@MinScore			INT, 
	@MaxScore			INT,
	@State				INT,
	--List for id Lucene
	@IdSolutionsList VARCHAR(500),
	@UserId				INT,
	@Count INT OUTPUT
)
AS
	BEGIN
		DECLARE @filterLenght AS INT
		SET		@filterLenght=0
		SELECT	@IdSolutionsList=REPLACE(@IdSolutionsList,'''','')
		
		--List Gets in Lucene
		IF (LEN(@IdSolutionsList)>0)
		BEGIN
			SELECT @filterLenght+=COUNT(Data) FROM dbo.Split(@IdSolutionsList, ',')
	    END


		DECLARE @tmpTable TABLE(
		RowNum BIGINT not null,
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
	    Score INTEGER not null
		
		);
		
		
		INSERT INTO @tmpTable 
		
		SELECT  
				ROW_NUMBER() OVER (ORDER BY dbo.GetScore(SLN.SolutionId,'JUDGE') DESC) AS RowNum,
				SLN.SolutionId AS SSolutionId, 
				SLN.SolutionTypeId AS SSolutionTypeId, 
				SLN.Title AS STitle, 
				SLN.TagLine AS STagLine,  
				SLN.[Description] AS SDescription, 
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
				SLN.[Language] AS SLanguage, 
				SLN.CreatedUserId AS SCreatedUserId, 
				SLN.Deleted AS SDeleted,  
				SLN.Country AS SCountry, 
				SLN.Region AS SRegion, 
				SLN.City AS SCity, 
				SLN.[Address] AS SAddress,  
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
				ORG.[Address] AS OAddress, 
				ORG.Phone AS OPhone,  
				ORG.Email AS OEmail, 
				ORG.ContactEmail AS OContactEmail, 
				ORG.Website AS OWebsite, 
				ORG.Twitter AS OTwitter,  
				ORG.Skype AS OSkype, 
				ORG.Facebook AS OFacebook, 
				ORG.GooglePlus AS OGooglePlus,  
				ORG.LinkedIN AS OLinkedIn, 
				ORG.[Description] AS ODescription, 
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
	        	(@MinScore='' OR @MinScore IS NULL OR dbo.GetScore(SLN.SolutionId,'JUDGE')>= @MinScore) 
				AND (@State IS NULL OR SLN.SolutionState >= @State )
				AND (@UserId=-1 OR CreatedUserId=@UserId) 
				AND (SLN.Deleted = 0 OR SLN.Deleted IS NULL)
				AND (						
					  SLN.SolutionId IN ( 		
						    				SELECT	solutionid AS SolutionIdList 
													FROM	SolutionLists
														WHERE (CONVERT(VARCHAR(60), SolutionId)) IN (SELECT Data FROM dbo.Split(@IdSolutionsList, ','))
														
									 				 GROUP BY solutionid
													
										)
					)
			
ORDER BY score	 DESC	
	 SELECT	@Count=COUNT(*)
		FROM @tmpTable

		SELECT	* 
		FROM	@tmpTable AS SOD
		WHERE	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		ORDER BY score	DESC	
	END