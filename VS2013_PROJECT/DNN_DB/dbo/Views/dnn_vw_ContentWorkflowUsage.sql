CREATE VIEW [dbo].[dnn_vw_ContentWorkflowUsage]
AS
    SELECT ci.Content as 'ContentName', ct.ContentType, ws.WorkflowID 
	FROM dbo.[dnn_ContentItems] ci
		INNER JOIN dbo.[dnn_ContentTypes] ct
			ON ci.ContentTypeID = ct.ContentTypeID
		INNER JOIN dbo.[dnn_ContentWorkflowStates] ws 
			ON ci.StateID = ws.StateID
	WHERE ct.ContentType != 'Tab' -- Tabs will be managed specifically
		AND ct.ContentType != 'File' -- Exclude Files
	UNION ALL
	SELECT t.TabPath, ct.ContentType, ws.WorkflowID 
	FROM dbo.[dnn_ContentItems] ci
		INNER JOIN dbo.[dnn_ContentTypes] ct
			ON ci.ContentTypeID = ct.ContentTypeID
		INNER JOIN dbo.[dnn_Tabs] t
			ON ci.TabID = t.TabID
		INNER JOIN dbo.[dnn_ContentWorkflowStates] ws 
			ON ci.StateID = ws.StateID
	WHERE ct.ContentType = 'Tab'
		AND LOWER(t.TabPath) not like '//admin/%'
		AND LOWER(t.TabPath) != '//admin'
		AND t.IsSystem = 0
		AND LOWER(t.TabPath) not like '//host/%'
		AND LOWER(t.TabPath) != '//host'
		AND ci.StateID IS NOT NULL
	UNION ALL
	SELECT t.TabPath, ct.ContentType, 
		(SELECT CAST(ps.SettingValue AS INT) value 
			FROM dbo.[dnn_PortalSettings] ps
			WHERE ps.SettingName = 'DefaultTabWorkflowKey' 
			AND ps.PortalID = t.PortalID) as WorkflowID 
	FROM dbo.[dnn_ContentItems] ci
		INNER JOIN dbo.[dnn_ContentTypes] ct
			ON ci.ContentTypeID = ct.ContentTypeID
		INNER JOIN dbo.[dnn_Tabs] t
			ON ci.TabID = t.TabID
	WHERE ct.ContentType = 'Tab'
		AND LOWER(t.TabPath) NOT LIKE '//admin/%'
		AND LOWER(t.TabPath) != '//admin'
		AND t.IsSystem = 0
		AND LOWER(t.TabPath) NOT LIKE '//host/%'
		AND LOWER(t.TabPath) != '//host'
		AND ci.StateID IS NULL
	UNION ALL
	SELECT '/' + f.FolderPath, 'Folder', f.WorkflowID 
	FROM dbo.[dnn_Folders] f
	WHERE f.WorkflowID IS NOT NULL
	UNION ALL
	SELECT '/' + f.FolderPath, 'Folder', 
		(SELECT wf.WorkflowID 
			FROM dbo.[dnn_ContentWorkflows] wf
			WHERE wf.WorkflowKey = 'DirectPublish' 
			AND wf.PortalID = f.PortalID) AS WorkflowID 
	FROM dbo.[dnn_Folders] f
	WHERE f.WorkflowID IS NULL

