CREATE FUNCTION [dbo].[dnn_fn_GetVersion]
(
	@maj AS int,
	@min AS int,
	@bld AS int
)
RETURNS bit

AS
BEGIN
	IF Exists (SELECT * FROM dbo.dnn_Version
					WHERE Major = @maj
						AND Minor = @min
						AND Build = @bld
				)
		BEGIN
			RETURN 1
		END
	RETURN 0
END

