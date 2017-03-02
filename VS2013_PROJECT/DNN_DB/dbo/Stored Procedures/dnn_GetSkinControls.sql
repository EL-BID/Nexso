CREATE PROCEDURE [dbo].[dnn_GetSkinControls]
AS
    SELECT *
    FROM   dbo.dnn_SkinControls
	ORDER BY  ControlKey

