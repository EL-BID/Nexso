using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DotNetNuke.Services.Scheduling;
using NexsoProBLL;
using NexsoProDAL;
using DotNetNuke.Entities.Modules;
using DotNetNuke.Services.Exceptions;
using System.Globalization;

namespace NexsoScheduler
{
    public class EmailCampaing : SchedulerClient
    {
        public EmailCampaing(ScheduleHistoryItem oItem)
            : base()
        {
            this.ScheduleHistoryItem = oItem;
        }


        public override void DoWork()
        {

            try
            {

                DateTime dateTime = DateTime.Now;
                List<Campaign> listCampaign = CampaignComponent.GetCampaigns().ToList();

                if (listCampaign != null && listCampaign.Count > 0)
                {

                    listCampaign = listCampaign.Where(a => a.Deleted == false && a.Status != "Inactive").ToList();
                    if (listCampaign != null && listCampaign.Count > 0)
                    {

                        foreach (Campaign campaignItem in listCampaign)
                        {

                          
                           if (Convert.ToDateTime(campaignItem.NextExecution)<DateTime.Now)
                            {
                                CampaignComponent campaignComponent = new CampaignComponent(campaignItem.CampaignId);

                                var result = MailServices.ProcessXmlFilter(campaignItem.CampaignId, "", 0, campaignItem.FilterTemplate, 0);

                                var createdOn = DateTime.Now;
                                foreach (var item in result)
                                {
                                    MailServices.CreateMailLog((Guid)campaignItem.CampaignId, campaignComponent.Campaign.TrackKey, campaignComponent.Campaign.Attemps, item.MailContent, item.MailSubject, item.email, Convert.ToInt32(item.userId), item.CampaignLogId, createdOn);
                                }
                                campaignComponent.Campaign.Attemps++;

                                switch (Convert.ToInt32(campaignItem.Repeat))
                                {
                                    case 0:
                                        campaignComponent.Campaign.NextExecution = new DateTime(9999, 12, 31);
                                        break;
                                    case 1:
                                    case 7:
                                        campaignComponent.Campaign.NextExecution = campaignItem.NextExecution.Value.AddDays(Convert.ToInt32(campaignItem.Repeat));
                                        break;
                                    case 30:
                                        campaignComponent.Campaign.NextExecution = campaignItem.NextExecution.Value.AddMonths(1);
                                        break;
                                }
                                if(campaignComponent.Save()==-1){
                                    this.ScheduleHistoryItem.Succeeded = false;
                                    Exception ee = new Exception("error database");
                                    DotNetNuke.Services.Exceptions.Exceptions.LogException(ee);
                                   
                                }
                            }
                        }
                    }

                }

                this.ScheduleHistoryItem.AddLogNote("Schedule Succeded");

                ////Show success
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
