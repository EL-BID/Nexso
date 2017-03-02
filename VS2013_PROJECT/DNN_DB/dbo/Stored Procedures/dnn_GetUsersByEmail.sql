CREATE PROCEDURE [dbo].[dnn_GetUsersByEmail]
	@PortalID  int,
	@EmailToMatch   nvarchar(256),
	@PageIndex      int,
	@PageSize       INT,
	@IncludeDeleted bit,
	@SuperUsersOnly bit		
AS
BEGIN
		-- Set the page bounds
		DECLARE 
			@PageLowerBound INT, 
			@PageUpperBound INT, 
			@RowsToReturn int, 
			@TotalRecords int

		exec dbo.dnn_CalculatePagingInformation @PageIndex, @PageSize, @RowsToReturn output, @PageLowerBound output, @PageUpperBound output

		declare @tblPageIndex table (
			IndexId int IDENTITY (0, 1) NOT NULL primary key,
			UserId int
		 )

		if @PortalId is null and @EmailToMatch IS NULL
			begin
				with [UsersByEmail] as (
					SELECT U.*, ROW_NUMBER() OVER (ORDER BY Email ASC) AS ROWID
						FROM    dbo.dnn_vw_Users U
						WHERE U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							--less than equal done to cover IsDeleted in (1,0) for IncludeDeleted...else just IsDeleted = 0
							AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				)
				select *, ROWID - 1 AS IndexID, UserID 
					from [UsersByEmail]
					where ROWID > @PageLowerBound AND ROWID < @PageUpperBound
			end
		else if @PortalId is null and @EmailToMatch IS NOT NULL 
			begin
				with [UsersByEmail] as (
					SELECT U.*, ROW_NUMBER() OVER (ORDER BY Email ASC) AS ROWID
						FROM    dbo.dnn_vw_Users U
						WHERE LOWER(U.Email) LIKE LOWER(@EmailToMatch)
							AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
					)
					select *, ROWID - 1 AS IndexID, UserID 
						from [UsersByEmail]
						where ROWID > @PageLowerBound AND ROWID < @PageUpperBound
			end
		else if @EmailToMatch IS NULL 
			begin
				with [UsersByEmail] as (
					SELECT U.*, ROW_NUMBER() OVER (ORDER BY Email ASC) AS ROWID
						FROM    dbo.dnn_vw_Users U
						WHERE U.PortalId = @PortalID
							AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				)
				select *, ROWID - 1 AS IndexID, UserID 
					from [UsersByEmail]
					where ROWID > @PageLowerBound AND ROWID < @PageUpperBound
		  end
		else
			begin
				with [UsersByEmail] as (
					SELECT U.*, ROW_NUMBER() OVER (ORDER BY Email ASC) AS ROWID
						FROM    dbo.dnn_vw_Users U
						WHERE U.PortalId = @PortalID
							AND LOWER(U.Email) LIKE LOWER(@EmailToMatch)
							AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
							AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
				)
				select *, ROWID - 1 AS IndexID, UserID 
					from [UsersByEmail]
					where ROWID > @PageLowerBound AND ROWID < @PageUpperBound
			end
	 
		if @PortalId is null and @EmailToMatch IS NULL
			begin
				SELECT count(*) as TotalRecords
					FROM    dbo.dnn_vw_Users U
					WHERE U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
						AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
			end 
		else if @PortalId is null and @EmailToMatch IS NOT NULL 
			begin
				SELECT count(*) as TotalRecords
					FROM    dbo.dnn_vw_Users U
					WHERE LOWER(U.Email) LIKE LOWER(@EmailToMatch)
						AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
						AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
			end 
		else if @EmailToMatch IS NULL 
			begin
				SELECT count(*) as TotalRecords
					FROM    dbo.dnn_vw_Users U
					WHERE U.PortalId = @PortalID
						AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
						AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
			end 
		else 
			begin
				SELECT count(*) as TotalRecords
					FROM    dbo.dnn_vw_Users U
					WHERE U.PortalId = @PortalID
						AND LOWER(U.Email) LIKE LOWER(@EmailToMatch)
						AND U.IsDeleted <= CASE @IncludeDeleted WHEN 0 THEN 0 ELSE 1 END
						AND U.IsSuperUser >= CASE @SuperUsersOnly WHEN 1 THEN 1 ELSE 0 END
		end
	END

