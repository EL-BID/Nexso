CREATE PROCEDURE [dbo].[dnn_GetAllUsers]
	@PortalID        int,
	@PageIndex       int,
	@PageSize        INT,
	@IncludeDeleted  bit,
	@SuperUsersOnly  bit	
AS
	BEGIN
		-- Set the page bounds
		DECLARE 
			@PageLowerBound INT, 
			@PageUpperBound INT, 
			@RowsToReturn int

		EXEC dbo.dnn_CalculatePagingInformation @PageIndex, @PageSize, @RowsToReturn output, @PageLowerBound output, @PageUpperBound output

		IF @PortalID IS NULL
			BEGIN
				WITH [tmpUsers] AS (
					SELECT U.*, row_number() over (ORDER BY U.UserName) AS rowid
						FROM dbo.dnn_vw_Users u
						WHERE U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							--less than equal done to cover IsDeleted in (1,0) for IncludeDeleted...else just IsDeleted = 0
							  AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				)
				SELECT * FROM [tmpUsers]
					WHERE rowid > @PageLowerBound AND rowid < @PageUpperBound
					ORDER BY rowid
			END 
		ELSE 
			BEGIN
				WITH [tmpUsers] AS (
					SELECT U.*, row_number() over (order by U.UserName) AS rowid
						FROM dbo.dnn_vw_Users u
						WHERE U.PortalID = @PortalID AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
						  AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				)
				SELECT * FROM [tmpUsers]
					WHERE rowid > @PageLowerBound AND rowid < @PageUpperBound
					ORDER by rowid
			END

		SET ROWCOUNT 0
 
		IF @PortalId IS NULL
			BEGIN
				SELECT COUNT(*) as TotalRecords
					FROM   dbo.dnn_vw_Users as U
					WHERE U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
				          AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
			END 
		ELSE 
			BEGIN
				SELECT COUNT(*) as TotalRecords
					FROM   dbo.dnn_vw_Users U
						WHERE U.PortalId = @PortalId
							AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
			END
	END

