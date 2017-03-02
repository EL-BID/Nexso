CREATE PROCEDURE [dbo].[dnn_GetPortalsByName]

    @NameToMatch	nvarchar(256),
    @PageIndex			int,
    @PageSize			int
AS
	BEGIN
		-- Set the page bounds
		DECLARE @PageLowerBound INT
		DECLARE @PageUpperBound INT
		SET @PageLowerBound = @PageSize * @PageIndex
		SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

		-- Create a temp table TO store the select results
		CREATE TABLE #PageIndexForPortals
		(
			IndexId int IDENTITY (0, 1) NOT NULL,
			PortalId int
		)

		-- Insert into our temp table
		INSERT INTO #PageIndexForPortals (PortalId)
			SELECT PortalId FROM	dbo.dnn_vw_PortalsDefaultLanguage
			WHERE  PortalName LIKE @NameToMatch
			ORDER BY PortalName

		SELECT  *
		FROM	dbo.dnn_vw_PortalsDefaultLanguage p, 
				#PageIndexForPortals i
		WHERE  p.PortalId = i.PortalId
				AND i.IndexId >= @PageLowerBound AND i.IndexId <= @PageUpperBound
		ORDER BY p.PortalName

		SELECT  TotalRecords = COUNT(*)
		FROM    #PageIndexForPortals
	END

