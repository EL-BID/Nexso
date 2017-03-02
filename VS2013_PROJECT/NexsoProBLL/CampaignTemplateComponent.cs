using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class CampaignTemplateComponent
    {
         private CampaignTemplate campaignTemplate;
        private MIFNEXSOEntities mifnexsoEntities;
        public CampaignTemplate CampaignTemplate
        {
            get { return campaignTemplate; }
        }

        public CampaignTemplateComponent(Guid templateId)
        {
            if (templateId != Guid.Empty )
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    campaignTemplate = mifnexsoEntities.CampaignTemplates.FirstOrDefault(a => a.TemplateId == templateId);


                    if (campaignTemplate == null)
                    {
                        campaignTemplate = new CampaignTemplate();
                        campaignTemplate.TemplateId = Guid.Empty;

                        mifnexsoEntities.CampaignTemplates.AddObject(campaignTemplate);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                campaignTemplate = new CampaignTemplate();
            }
        }

        public int Save()
        {
            try
            {
                if (campaignTemplate.TemplateId == Guid.Empty)
                    campaignTemplate.TemplateId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(campaignTemplate);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = campaignTemplate.EntityState;
            if (campaignTemplate.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(campaignTemplate);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.CampaignTemplates.AddObject(campaignTemplate);
                else
                    mifnexsoEntities.CampaignTemplates.Attach(campaignTemplate);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region

        public static List<CampaignTemplate> GetTemplateLists(string language )
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignTemplates

                         where c.Language == language

                         select c;

            return result.ToList();
        }

        public static List<CampaignTemplate> GetTemplateLists()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignTemplates

                        

                         select c;

            return result.ToList();
        }
        #endregion
    }
}
