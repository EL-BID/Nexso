CREATE PROCEDURE [dbo].[dnn_EasyDNNNewsCategoryPositioning]
	@PortalID int,
	@CategoryID int,
	@Operation nvarchar(20)
AS
SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
DECLARE @Position int;
DECLARE @Parent int;
DECLARE @NewParent int;
DECLARE @Level int;
DECLARE @UpRootCategoryID int;
DECLARE @DownRootCategoryID int;
DECLARE @UpNewPosition int;
DECLARE @DownNewPosition int;

SELECT @Position = [Position] ,@Parent = [ParentCategory], @Level = [Level] FROM dbo.[dnn_EasyDNNNewsCategoryList] WHERE CategoryID = @CategoryID;
IF @Position IS NOT NULL
BEGIN
	IF @Operation = 'Left'
	BEGIN	
		IF @Level > 0 AND @Parent <> 0
		BEGIN	
			DECLARE @DownCount int;
			;WITH sibblings AS(
				SELECT [CategoryID],[Position],[Level] FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @Parent AND cl.Position > @Position AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position],c.[Level]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN sibblings AS s ON c.ParentCategory = s.CategoryID WHERE c.PortalID = @PortalID
			)
			SELECT @DownCount = Count([CategoryID]) FROM sibblings
			-- change position of all down inner elements
			IF @DownCount > 0
			BEGIN
				;WITH sibblings AS(
					SELECT [CategoryID],[Position]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
					WHERE cl.ParentCategory = @Parent AND cl.Position > @Position AND PortalID = @PortalID
					UNION ALL
					SELECT c.[CategoryID], c.[Position]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN sibblings AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
				),
				OrderAll AS(
					SELECT [CategoryID], ROW_NUMBER() OVER (ORDER BY Position ASC) AS PositionsOrder FROM sibblings
				)
				UPDATE cl SET cl.Position = (@Position - 1 + cpm.PositionsOrder) FROM dbo.[dnn_EasyDNNNewsCategoryList] as cl INNER JOIN OrderAll as cpm ON cl.CategoryID = cpm.CategoryID;
			END		
			-- change parent and postion of mooving category		
			SELECT @NewParent = cl.ParentCategory FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl WHERE cl.CategoryID = @Parent AND cl.PortalID = @PortalID;	
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET [ParentCategory] = @NewParent, [Position] = (@Position + @DownCount), [Level] = [Level] - 1 WHERE CategoryID = @CategoryID;
			-- find all childe categories and set level - 1
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @CategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			),
			OrderAll AS(
				SELECT [CategoryID], ROW_NUMBER() OVER (ORDER BY Position ASC) AS Offset FROM Childes
			)
			UPDATE cl SET cl.Position = (@Position + @DownCount + Offset), cl.[Level] = cl.[Level] - 1 FROM dbo.[dnn_EasyDNNNewsCategoryList] as cl INNER JOIN OrderAll as cpm ON cl.CategoryID = cpm.CategoryID;
		END
	END
	ELSE IF @Operation = 'Right'
	BEGIN
		SELECT @NewParent = CategoryID FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl WHERE cl.Position = @Position - 1 AND cl.[Level] = @Level AND cl.PortalID = @PortalID;
		IF @NewParent IS NOT NULL -- then are same level 
		BEGIN
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET [ParentCategory] = @NewParent, [Level] = [Level] + 1 WHERE CategoryID = @CategoryID;
				-- find all childe categories and set level + 1
			;WITH Childes AS(
				SELECT [CategoryID]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @CategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET [Level] = [Level] + 1 WHERE [CategoryID] IN (SELECT [CategoryID] FROM Childes);	
		END
		ELSE
		BEGIN
			SELECT TOP (1) @NewParent = cl.CategoryID, @UpNewPosition = cl.Position FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @Parent AND cl.PortalID = @PortalID AND cl.Position < @Position ORDER BY cl.Position DESC			
			
			IF @NewParent IS NOT NULL
			BEGIN		
				UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET [ParentCategory] = @NewParent, [Level] = [Level] + 1 WHERE CategoryID = @CategoryID;			
				-- find all childe categories and set level + 1
				;WITH Childes AS(
					SELECT [CategoryID]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
					WHERE cl.ParentCategory = @CategoryID AND PortalID = @PortalID
					UNION ALL
					SELECT c.[CategoryID]
					FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
				)
				UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET [Level] = [Level] + 1 WHERE [CategoryID] IN (SELECT [CategoryID] FROM Childes);	
			END
		END
	END
	ELSE IF @Operation = 'UP'
	BEGIN
		-- parentCategory is the same
		-- level is the same
		-- positions order is changeing	
		-- main two exchange nodes (inner root nodes)
		SELECT TOP (1) @DownRootCategoryID = cl.CategoryID, @UpNewPosition = cl.Position FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE cl.ParentCategory = @Parent AND cl.Position < @Position AND cl.PortalID = @PortalID ORDER BY cl.Position DESC
			
		IF @DownRootCategoryID IS NOT NULL -- if null then this is first sibbling and cannot move up
		BEGIN
			-- up root node
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET Position = @UpNewPosition WHERE CategoryID = @CategoryID;
			-- Exchange childes positions
			-- up node childe''s		
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @CategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			),
			ChildesPositionsMath AS(
				SELECT [CategoryID], ROW_NUMBER() OVER (ORDER BY Position ASC) AS offset FROM Childes
			)
			UPDATE cl SET cl.Position = (@UpNewPosition + cpm.offset) FROM dbo.[dnn_EasyDNNNewsCategoryList] as cl INNER JOIN ChildesPositionsMath as cpm ON cl.CategoryID = cpm.CategoryID;
			-- down node
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @CategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
			SELECT @DownNewPosition = ( COUNT([Position]) + @UpNewPosition + 1) FROM Childes;		
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET Position = @DownNewPosition WHERE CategoryID = @DownRootCategoryID;		
			-- down node childe''s	
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @DownRootCategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			),
			ChildesPositionsMath AS(
				SELECT [CategoryID], ROW_NUMBER() OVER (ORDER BY Position ASC) AS offset FROM Childes
			)
			UPDATE cl SET cl.Position = (@DownNewPosition + cpm.offset) FROM dbo.[dnn_EasyDNNNewsCategoryList] as cl INNER JOIN ChildesPositionsMath as cpm ON cl.CategoryID = cpm.CategoryID;
			-- all other Categories on portal position won''t change
		END
	END	
	ELSE IF @Operation = 'DOWN'
	BEGIN
		-- main two exchange nodes (inner root nodes)		
		SELECT TOP (1) @UpRootCategoryID = cl.CategoryID, @DownNewPosition = cl.Position FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
			WHERE cl.ParentCategory = @Parent AND cl.Position > @Position AND cl.PortalID = @PortalID ORDER BY cl.Position ASC
			
		IF @UpRootCategoryID IS NOT NULL -- if null then this is last sibbling and cannot move down
		BEGIN
			-- up root node
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET Position = @Position WHERE CategoryID = @UpRootCategoryID;
			-- Exchange childes positions
			-- up node childe''s		
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @UpRootCategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			),
			ChildesPositionsMath AS(
				SELECT [CategoryID], ROW_NUMBER() OVER (ORDER BY Position ASC) AS offset FROM Childes
			)
			UPDATE cl SET cl.Position = (@Position + cpm.offset) FROM dbo.[dnn_EasyDNNNewsCategoryList] as cl INNER JOIN ChildesPositionsMath as cpm ON cl.CategoryID = cpm.CategoryID;
			-- down node
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @UpRootCategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			)
			SELECT @UpNewPosition = ( COUNT([Position]) + @Position + 1 ) FROM Childes;		
			UPDATE dbo.[dnn_EasyDNNNewsCategoryList] SET Position = @UpNewPosition WHERE CategoryID = @CategoryID;
			
			-- down node childe''s
			
			;WITH Childes AS(
				SELECT [CategoryID],[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS cl
				WHERE cl.ParentCategory = @CategoryID AND PortalID = @PortalID
				UNION ALL
				SELECT c.[CategoryID],c.[Position]
				FROM dbo.[dnn_EasyDNNNewsCategoryList] AS c INNER JOIN Childes AS p ON c.ParentCategory = p.CategoryID WHERE c.PortalID = @PortalID
			),
			ChildesPositionsMath AS(
				SELECT [CategoryID], ROW_NUMBER() OVER (ORDER BY Position ASC) AS offset FROM Childes
			)
			UPDATE cl SET cl.Position = (@UpNewPosition + cpm.offset) FROM dbo.[dnn_EasyDNNNewsCategoryList] as cl INNER JOIN ChildesPositionsMath as cpm ON cl.CategoryID = cpm.CategoryID;		
			-- all other Categories on portal position won''t change
		END
	END
END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;
IF @@TRANCOUNT > 0
    COMMIT TRANSACTION;

