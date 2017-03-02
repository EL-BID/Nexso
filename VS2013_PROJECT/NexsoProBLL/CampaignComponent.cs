using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class CampaignComponent
    {
        private Campaign campaign;
        private MIFNEXSOEntities mifnexsoEntities;

        public Campaign Campaign
        {
            get { return campaign; }
        }

        public CampaignComponent(Guid CampaignId)
        {
            if (CampaignId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    campaign = mifnexsoEntities.Campaigns.FirstOrDefault(a => a.CampaignId == CampaignId);


                    if (campaign == null)
                    {
                        campaign = new Campaign();
                        campaign.CampaignId = Guid.Empty;

                        mifnexsoEntities.Campaigns.AddObject(campaign);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                campaign = new Campaign();
            }
        }

        public CampaignComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            campaign = new Campaign();
            campaign.CampaignId = Guid.Empty;

            mifnexsoEntities.Campaigns.AddObject(campaign);

        }

        public int Save()
        {
            try
            {
                if (campaign.CampaignId == Guid.Empty)
                    campaign.CampaignId = Guid.NewGuid();
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }


        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(campaign);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = campaign.EntityState;
            if (campaign.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(campaign);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Campaigns.AddObject(campaign);
                else
                    mifnexsoEntities.Campaigns.Attach(campaign);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region

        public static List<Campaign> GetCampaigns()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Campaigns

                         

                         select c;

            return result.ToList();
        }

        #endregion
    }
}
