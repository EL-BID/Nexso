CREATE PROCEDURE [dbo].[dnn_GetSkinControlByKey]
	@ControlKey	nvarchar(50)
AS
    SELECT *
    FROM   dbo.dnn_SkinControls
	WHERE ControlKey = @ControlKey

