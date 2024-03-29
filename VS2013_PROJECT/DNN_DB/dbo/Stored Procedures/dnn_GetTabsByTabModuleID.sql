﻿CREATE PROCEDURE [dbo].[dnn_GetTabsByTabModuleID]
	@TabModuleID Int -- NOT Null
AS
	BEGIN
		SELECT * FROM dbo.[dnn_vw_Tabs] T
		WHERE IsDeleted = 0
		  AND TabID IN (SELECT TabID FROM dbo.[dnn_TabModules]
						WHERE TabModuleID = @TabModuleID AND IsDeleted = 0)
		ORDER BY PortalId, Level, ParentID, TabOrder -- PortalId added for query optimization
	END

