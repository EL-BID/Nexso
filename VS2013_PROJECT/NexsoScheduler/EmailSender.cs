using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DotNetNuke.Services.Scheduling;
using System.Web;
using System.Configuration;
using NexsoProBLL;
using NexsoProDAL;
using System.Globalization;
using DotNetNuke.Entities.Tabs;
using DotNetNuke.Entities.Portals;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Entities.Modules.Definitions;
using System.Collections;
using DotNetNuke.UI.Skins;


namespace NexsoScheduler
{
    public class EmailSender : SchedulerClient
    {
        public EmailSender(ScheduleHistoryItem oItem)
            : base()
        {
            this.ScheduleHistoryItem = oItem;
        }


        public override void DoWork()
        {
            try
            {
                

                var mifnexsoEntities = new MIFNEXSOEntities();
                var listCampaignLog = from c in mifnexsoEntities.CampaignLogs where c.Status == "NEW" select c; 

                foreach (var item in listCampaignLog.Take(100))
                {
                    CampaignLogComponent campaignLogComponent = new CampaignLogComponent(item.CampaignLogId);
                    try
                    {
                        var img = string.Format(@"<div style=""display:none""><img src=""{0}clog/" + item.CampaignLogId + "\" /></div>", "http://www.nexso.org/en-us/cheese/");

                        item.MailContent += img;
                        campaignLogComponent.CampaignLog.SentOn = DateTime.Now;
                        campaignLogComponent.CampaignLog.Status = "SENT";
                        if (campaignLogComponent.Save() == -1)
                        {
                            this.ScheduleHistoryItem.Succeeded = false;
                            Exception ee = new Exception("error database cheese");
                            DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);

                        }
                        else
                        {
                            DotNetNuke.Services.Mail.Mail.SendEmail("nexso@nexso.org", item.email, item.MailSubject, item.MailContent);
                            System.Threading.Thread.Sleep(5500);
                        }

                    }
                    catch
                    {
                        campaignLogComponent.CampaignLog.Status = "ERROR";
                        if (campaignLogComponent.Save() == -1)
                        {
                            this.ScheduleHistoryItem.Succeeded = false;
                            Exception ee = new Exception("error database cheese 2");
                            DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);
                            // return;
                        }

                    }

                }


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
