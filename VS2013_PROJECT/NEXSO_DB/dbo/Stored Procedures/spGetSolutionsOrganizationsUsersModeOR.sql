-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetSolutionsOrganizationsUsersModeOR]
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
	@Joly				varchar(500)
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
		
		

		SELECT	* 
		FROM	(	SELECT	ROW_NUMBER() OVER (ORDER BY dbo.GetScore(SLN.SolutionId,'JUDGE') desc) AS RowNum,
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
							dbo.GetScore(SLN.SolutionId,'JUDGE') AS Score,
							USR.FirstName,
							USR.LastName,
							USR.City,
							USR.Country,
							USR.email,
							USR.Telephone,
							USR.[Address]
					FROM	dbo.Solution AS SLN
							INNER JOIN dbo.Organization AS ORG ON SLN.OrganizationId = ORG.OrganizationID 
							INNER JOIN dbo.UserProperties AS USR ON SLN.CreatedUserId=USR.UserId
					WHERE	(@ChallengeReference='%' OR @ChallengeReference='' OR @ChallengeReference IS NULL OR SLN.ChallengeReference LIKE @ChallengeReference)
					and (@SolutionType='%' OR @SolutionType='' OR @SolutionType IS NULL OR SLN.SolutionType LIKE @SolutionType)
					and (@Language='%' OR @Language='' OR @Language IS NULL OR SLN.Language LIKE @Language)
							AND (@MinScore='' OR @MinScore IS NULL OR dbo.GetScore(SLN.SolutionId,'JUDGE')>= @MinScore) 
							AND (@State IS NULL OR SLN.SolutionState >= @State )
							AND (@UserId=-1 OR CreatedUserId=@UserId) 
							AND (((@Categories = '' AND @Beneficiaries = '' AND @DeliveryFormat = '')OR(@Categories IS NULL AND @Beneficiaries IS NULL AND @DeliveryFormat IS NULL) ) OR SLN.SolutionId IN (
							
							SELECT	distinct solutionid AS SolutionIdList 
														
	FROM	SolutionLists
	WHERE	((Category='Beneficiaries' AND [KEY] IN (SELECT Data FROM dbo.Split(@Beneficiaries, ','))) 
or (Category='Theme' AND [KEY] IN (SELECT Data FROM dbo.Split(@Categories, ',')))
or (Category='DeliveryFormat' AND [KEY] IN (SELECT Data FROM dbo.Split(@DeliveryFormat, ','))))  
														
					
	
									
																
														))
					        AND (@searchString='*' or freetext((Title, TagLine),@searchString))
					) AS SOD
		WHERE	SOD.RowNum BETWEEN ((@PageNumber-1)*@RowsPerPage)+1
				AND @RowsPerPage*(@PageNumber)
		
	END
