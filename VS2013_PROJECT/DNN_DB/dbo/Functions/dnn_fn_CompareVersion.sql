CREATE FUNCTION [dbo].[dnn_fn_CompareVersion]
(
	@Version		nvarchar(20),
	@CurrentVersion nvarchar(20)
)
RETURNS int

AS
	BEGIN
	
		DECLARE @Pos int
		DECLARE @String nvarchar(20)
		DECLARE @MajorVersion int
		DECLARE @MajorCurrentVersion int
		DECLARE @MinorVersion int
		DECLARE @MinorCurrentVersion int
		DECLARE @BuildVersion int
		DECLARE @BuildCurrentVersion int

		SET @String = @Version
		SET @Pos = CHARINDEX('.' , @String)
		SET @MajorVersion = CONVERT(int, LEFT(@String, @Pos - 1))
		SET @String = STUFF(@String, 1, @Pos, '')
		SET @Pos = CHARINDEX('.' , @String)
		SET @MinorVersion = CONVERT(int, LEFT(@String, @Pos - 1))
		SET @String = STUFF(@String, 1, @Pos, '')
		SET @BuildVersion = CONVERT(int, @String)
		
		SET @String = @CurrentVersion
		SET @Pos = CHARINDEX('.' , @String)
		SET @MajorCurrentVersion = CONVERT(int, LEFT(@String, @Pos - 1))
		SET @String = STUFF(@String, 1, @Pos, '')
		SET @Pos = CHARINDEX('.' , @String)
		SET @MinorCurrentVersion = CONVERT(int, LEFT(@String, @Pos - 1))
		SET @String = STUFF(@String, 1, @Pos, '')
		SET @BuildCurrentVersion = CONVERT(int, @String)
		
		IF @CurrentVersion IS NULL
			-- Assembly Not Registered -  Set ReturnCode = 0, so assembly is copied
			RETURN 0
		ELSE
			IF @Version = @CurrentVersion
				-- Same Version - Set ReturnCode = 2, so assembly is only copied on repair
				RETURN 2
			ELSE
				-- Different Version
				-- Compare Major, Minor, Revision
				IF @MajorVersion > @MajorCurrentVersion
					OR (@MajorVersion = @MajorCurrentVersion AND @MinorVersion > @MinorCurrentVersion)
						OR (@MajorVersion = @MajorCurrentVersion AND @MinorVersion = @MinorCurrentVersion AND @BuildVersion > @BuildCurrentVersion)
					-- Newer version - at least on of Major, Minor, Revision is larger - Set ReturnCode = 1, so assembly is copied
					RETURN 1
				ELSE
					-- Older Version - Set ReturnCode = 3, so assembly is not copied
					RETURN 3

		RETURN 3
	END

