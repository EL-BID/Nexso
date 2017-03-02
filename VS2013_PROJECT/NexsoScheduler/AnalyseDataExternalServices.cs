#region Using
using DotNetNuke.Services.Scheduling;
using System;
using NexsoIndex.Manage;
#endregion

namespace NexsoScheduler
{
    public class AnalyseDataExternalServices: SchedulerClient
    {
        public AnalyseDataExternalServices(ScheduleHistoryItem oItem)
            : base()
        {
            this.ScheduleHistoryItem = oItem;
        }

        public override void DoWork()
        {

            try
            {
                if (System.Configuration.ConfigurationManager.AppSettings["RunningEnviroment"] == "PRODUCTION")
                {

                    new AnalysisDataIndex().GetDataForIndex();
                    
                                        
                }

                this.ScheduleHistoryItem.Succeeded = true;
            }
            catch (Exception ex)
            {
                this.ScheduleHistoryItem.Succeeded = false;
                this.Errored(ref ex);
                DotNetNuke.Services.Exceptions.Exceptions.LogException(ex);
            }
        }
    }
}
