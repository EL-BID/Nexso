-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetDataIndex]
	
AS
BEGIN
	
SELECT 
     b.[ObjectId],
	 CONCAT(ISNULL(a.[Title],'')
			,ISNULL(a.[TagLine],'')
			,ISNULL(a.[Description],'')
			,ISNULL(a.[Challenge],'')
			,ISNULL(a.[Approach],'')
			,ISNULL(a.[Results],'')
			,ISNULL(a.[ImplementationDetails],'')) AS 'FullText',
	a.[Language],
    (SELECT TOP(1) c.Value FROM [dbo].[AnalysisData] AS c WHERE a.[SolutionId] = c.[ObjectId] and c.[TypeKey] = 'Sentences') AS Sentences,
    (SELECT TOP(1) d.Value FROM [dbo].[AnalysisData] AS d WHERE a.[SolutionId] = d.[ObjectId] and d.[TypeKey] = 'Keywords') AS Keywords,
    (SELECT TOP(1) e.Value FROM [dbo].[AnalysisData] AS e WHERE a.[SolutionId] = e.[ObjectId] and e.[TypeKey] = 'ConceptsMember') AS ConceptsMember,
	 STUFF(( SELECT distinct ', ' + sol.[Region] AS [text()] FROM [dbo].[SolutionLocations] as sol WHERE b.[ObjectId] = sol.[SolutionId] FOR XML PATH('') ), 1, 1, '' ) AS Region,
	 STUFF(( SELECT distinct ', ' + sol.[Country] AS [text()] FROM [dbo].[SolutionLocations] as sol WHERE b.[ObjectId] = sol.[SolutionId] FOR XML PATH('') ), 1, 1, '' ) AS Country,
	 STUFF(( SELECT distinct ', ' + sol.[City] AS [text()] FROM [dbo].[SolutionLocations] as sol WHERE b.[ObjectId] = sol.[SolutionId] FOR XML PATH('') ), 1, 1, '' ) AS City,
	 STUFF(( SELECT distinct ', ' + sol.[Category] AS [text()] FROM [dbo].[SolutionLists] as sol WHERE b.[ObjectId] = sol.[SolutionId] FOR XML PATH('') ), 1, 1, '' ) AS Category,
	 STUFF(( SELECT distinct ', ' + sol.[Key] AS [text()] FROM [dbo].[SolutionLists] as sol WHERE b.[ObjectId] = sol.[SolutionId] FOR XML PATH('') ), 1, 1, '' ) AS keys,
	 STUFF((SELECT distinct ', ' + lis.Label AS [text()] FROM [dbo].[Lists] AS lis 
			INNER JOIN [dbo].[SolutionLists] AS solL on solL.[Key] = lis.[Key]
			WHERE b.[ObjectId] = solL.[SolutionId] FOR XML PATH('') ), 1, 1, '') AS Label
FROM [dbo].[Solution] AS a
	 right join [dbo].[AnalysisData] AS b ON a.[SolutionId] = b.[ObjectId]
	 INNER JOIN [dbo].[SolutionLists] as c ON  a.[SolutionId] = b.[ObjectId] 
WHERE a.[Deleted] <> 1 and b.[Indexed] = 0
GROUP BY a.[SolutionId], b.[ObjectId], a.[Title] ,a.[TagLine] ,a.[Description] ,a.[Challenge] ,a.[Approach] ,a.[Results] 
		,a.[ImplementationDetails],a.[Language]
	
END