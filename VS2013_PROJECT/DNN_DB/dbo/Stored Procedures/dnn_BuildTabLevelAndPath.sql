CREATE PROCEDURE [dbo].[dnn_BuildTabLevelAndPath](@TabId INT, @IncludeChild BIT = 0)
	AS
	BEGIN
		DECLARE @ParentId INT, @Level INT, @TabPath NVARCHAR(255), @TabName NVARCHAR(200)
		SELECT @ParentId = ParentId, @TabName = TabName FROM dbo.[dnn_Tabs] WHERE TabID = @TabId
		IF @ParentId > 0
		BEGIN
			SELECT 
				@Level = [Level] + 1,
				@TabPath = TabPath + '//' + dbo.[dnn_RemoveStringCharacters](@TabName, '&? ./''#:*')
			 FROM dbo.[dnn_Tabs] WHERE TabID = @ParentId
		END
		ELSE
		BEGIN
			SELECT @Level = 0, @TabPath = '//' + dbo.[dnn_RemoveStringCharacters](@TabName, '&? ./''#:*')
		END
		
		UPDATE dbo.[dnn_Tabs] SET [Level] = @Level, TabPath = @TabPath WHERE TabID = @TabId
		
		IF @IncludeChild = 1
		BEGIN
			DECLARE @ChildTabs TABLE(TabID INT)
			DECLARE @ChildID INT
			INSERT INTO @ChildTabs SELECT TabID FROM dbo.[dnn_Tabs] WHERE ParentId =  @TabId
			WHILE EXISTS (SELECT TOP 1 TabID FROM @ChildTabs)
				BEGIN
					SET @ChildID = (SELECT TOP 1 TabID FROM @ChildTabs)
					EXEC dbo.[dnn_BuildTabLevelAndPath] @ChildID, @IncludeChild
					DELETE FROM @ChildTabs WHERE TabID = @ChildID
				END
		END
	END

