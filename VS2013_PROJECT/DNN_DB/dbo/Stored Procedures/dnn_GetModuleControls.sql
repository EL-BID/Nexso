CREATE PROCEDURE [dbo].[dnn_GetModuleControls]
AS
    SELECT *
    FROM   dbo.dnn_ModuleControls
	ORDER BY  ControlKey, ViewOrder

