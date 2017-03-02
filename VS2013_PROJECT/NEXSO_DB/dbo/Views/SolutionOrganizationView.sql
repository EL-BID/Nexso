CREATE VIEW [dbo].[SolutionOrganizationView]
AS
SELECT     dbo.Solution.SolutionId AS SSolutionId, dbo.Solution.SolutionTypeId AS SSolutionTypeId, dbo.Solution.Title AS STitle, dbo.Solution.TagLine AS STagLine, dbo.Solution.Description AS SDescription, 
                      dbo.Solution.Biography AS SBiography, dbo.Solution.Challenge AS SChallenge, dbo.Solution.Approach AS SApproach, dbo.Solution.Results AS SResults, 
                      dbo.Solution.ImplementationDetails AS SImplementationDetails, dbo.Solution.AdditionalCost AS SAdditionalCost, dbo.Solution.AvailableResources AS SAvailableResources, 
                      dbo.Solution.TimeFrame AS STimeFrame, dbo.Solution.Duration AS SDuration, dbo.Solution.DurationDetails AS SDurationDetails, dbo.Solution.SolutionStatusId AS SSolutionStatusId, 
                      dbo.Solution.SolutionType AS SSolutionType, dbo.Solution.Topic AS STopic, dbo.Solution.Language AS SLanguage, dbo.Solution.CreatedUserId AS SCreatedUserId, 
                      dbo.Solution.Deleted AS SDeleted, dbo.Solution.Country AS SCountry, dbo.Solution.Region AS SRegion, dbo.Solution.City AS SCity, dbo.Solution.Address AS SAddress, 
                      dbo.Solution.ZipCode AS SZipCode, dbo.Solution.Logo AS SLogo, dbo.Solution.Cost1 AS SCost1, dbo.Solution.Cost2 AS SCost2, dbo.Solution.Cost3 AS SCost3, 
                      dbo.Solution.DeliveryFormat AS SDeliveryFormat, dbo.Solution.Cost AS SCost, dbo.Solution.CostType AS SCostType, dbo.Solution.CostDetails AS SCostDetails, 
                      dbo.Solution.SolutionState AS SSolutionState, dbo.Solution.Beneficiaries AS SBeneficiaries, dbo.Solution.DateCreated AS SDateCreated, dbo.Solution.DateUpdated AS SDateUpdated, 
                      dbo.Solution.ChallengeReference AS SChallengeReference, dbo.Organization.OrganizationID AS OOrganizationID, dbo.Organization.Code AS OCode, dbo.Organization.Name AS OName, 
                      dbo.Organization.Address AS OAddress, dbo.Organization.Phone AS OPhone, dbo.Organization.Email AS OEmail, dbo.Organization.ContactEmail AS OContactEmail, 
                      dbo.Organization.Website AS OWebsite, dbo.Organization.Twitter AS OTwitter, dbo.Organization.Skype AS OSkype, dbo.Organization.Facebook AS OFacebook, 
                      dbo.Organization.GooglePlus AS OGooglePlus, dbo.Organization.LinkedIn AS OLinkedIn, dbo.Organization.Description AS ODescription, dbo.Organization.Logo AS OLogo, 
                      dbo.Organization.Country AS OCountry, dbo.Organization.Region AS ORegion, dbo.Organization.ZipCode AS OZipCode, dbo.Organization.City AS OCity, dbo.Organization.Created AS OCreated, 
                      dbo.Organization.Updated AS OUpdated, dbo.Organization.Latitude AS OLatitude, dbo.Organization.Longitude AS OLongitude, dbo.Organization.GoogleLocation AS OGoogleLocation, 
                      dbo.Solution.VideoObject
FROM         dbo.Solution INNER JOIN
                      dbo.Organization ON dbo.Solution.OrganizationId = dbo.Organization.OrganizationID


GO



GO


