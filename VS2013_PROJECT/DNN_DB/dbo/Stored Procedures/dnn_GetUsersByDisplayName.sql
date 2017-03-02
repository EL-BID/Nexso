CREATE PROCEDURE [dbo].[dnn_GetUsersByDisplayName]
    @PortalID		int,
    @NameToMatch	nvarchar(256),
    @PageIndex		int,
    @PageSize		INT,
    @IncludeDeleted     bit,
    @SuperUsersOnly     bit		
AS
	BEGIN
		-- Set the page bounds
		DECLARE @PageLowerBound INT
		DECLARE @PageUpperBound INT
		SET @PageLowerBound = @PageSize * @PageIndex
		SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

		-- Create a temp table TO store the select results
		CREATE TABLE #PageIndexForUsers
		(
			IndexId int IDENTITY (0, 1) NOT NULL,
			UserId int
		)

		-- Insert into our temp table
		INSERT INTO #PageIndexForUsers (UserId)
			SELECT UserId FROM	dbo.dnn_vw_Users 
			WHERE  DisplayName LIKE @NameToMatch
				AND (IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							--less than equal done to cover IsDeleted in (1,0) for IncludeDeleted...else just IsDeleted = 0
				     OR IsDeleted Is NULL)
			        AND IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				AND ( PortalId = @PortalID OR (@PortalID is null ))
			ORDER BY DisplayName

		SELECT  *
		FROM	dbo.dnn_vw_Users u, 
				#PageIndexForUsers p
		WHERE  u.UserId = p.UserId
				AND (IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							--less than equal done to cover IsDeleted in (1,0) for IncludeDeleted...else just IsDeleted = 0
				     OR IsDeleted Is NULL)
			        AND IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				AND ( PortalId = @PortalID OR (@PortalID is null ))
				AND p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
		ORDER BY u.DisplayName

		SELECT  TotalRecords = COUNT(*)
		FROM    #PageIndexForUsers
	END

