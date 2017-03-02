using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System;
using System.Collections.Generic;
using DotNetNuke.Services.Scheduling;

using System.Web;
using System.Configuration;

namespace NexsoScheduler
{
    class CampaingProcessor : SchedulerClient
    {


        public CampaingProcessor(ScheduleHistoryItem oItem)
            : base()
        {
            this.ScheduleHistoryItem = oItem;
        }

        public override void DoWork()
        {
            try
            {
                DotNetNuke.Services.Mail.Mail.SendEmail("nexso@iadb.org",
                                                                "jairoa@iadb.org", "purbea schedule", "prueba schedule");

                this.ScheduleHistoryItem.AddLogNote("Schedule Succeded");

                //Show success
                this.ScheduleHistoryItem.Succeeded = true;
            }
            catch (Exception ex)
            {
                this.ScheduleHistoryItem.Succeeded = false;
                //InsertLogNote("Exception= " + ex.ToString());
                this.Errored(ref ex);
                DotNetNuke.Services.Exceptions.Exceptions.LogException(ex);
            }
        }
    }
}
