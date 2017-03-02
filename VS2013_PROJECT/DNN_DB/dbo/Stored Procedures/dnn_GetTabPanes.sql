create procedure [dbo].[dnn_GetTabPanes]

@TabId    int

as

select distinct(PaneName) as PaneName
from   dbo.dnn_TabModules
where  TabId = @TabId
order by PaneName

