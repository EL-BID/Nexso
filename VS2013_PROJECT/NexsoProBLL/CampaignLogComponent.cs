using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class CampaignLogComponent
    {
        private CampaignLog campaignLog;
        private MIFNEXSOEntities mifnexsoEntities;
        public CampaignLog CampaignLog
        {
            get { return campaignLog; }
        }

        public CampaignLogComponent(Guid CampaignLogId, Guid CampaignId)
        {
            if (CampaignLogId != Guid.Empty && CampaignId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    campaignLog = mifnexsoEntities.CampaignLogs.FirstOrDefault(a => a.CampaignLogId == CampaignLogId && a.CampaignId == CampaignId);


                    if (campaignLog == null)
                    {
                        campaignLog = new CampaignLog();
                        campaignLog.CampaignId = CampaignId;
                        campaignLog.CampaignLogId = Guid.Empty;
                        mifnexsoEntities.CampaignLogs.AddObject(campaignLog);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                campaignLog = new CampaignLog();
            }
        }

        public CampaignLogComponent(Guid CampaignLogId)
        {
            if (CampaignLogId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    campaignLog = mifnexsoEntities.CampaignLogs.FirstOrDefault(a => a.CampaignLogId == CampaignLogId );


                    if (campaignLog == null)
                    {
                        campaignLog = new CampaignLog();
                        campaignLog.CampaignLogId = Guid.Empty;
                        mifnexsoEntities.CampaignLogs.AddObject(campaignLog);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                campaignLog = new CampaignLog();
                campaignLog.CampaignLogId = Guid.Empty;
                mifnexsoEntities.CampaignLogs.AddObject(campaignLog);
            }
        }

        public CampaignLogComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
        }

        public int Save()
        {
            try
            {
                if (campaignLog.CampaignLogId == Guid.Empty)
                    campaignLog.CampaignLogId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(campaignLog);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = campaignLog.EntityState;
            if (campaignLog.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(campaignLog);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.CampaignLogs.AddObject(campaignLog);
                else
                    mifnexsoEntities.CampaignLogs.Attach(campaignLog);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        #region

        public static List<CampaignLog> GetCampaignLog(Guid campaignId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignLogs
                         
                         where c.CampaignId==campaignId

                         select c;

            return result.ToList();
            

        }

        public static List<CampaignLog> GetCampaignLogByUserId(int userId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignLogs

                         where c.userId == userId

                         select c;

            return result.ToList();
           
        }
        public static List<CampaignLog> GetCampaignLogByUserId(int userId, Guid campaignId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignLogs

                         where c.CampaignId == campaignId && c.userId==userId

                         select c;

            return result.ToList();
            
        }

        public static List<CampaignLog> GetCampaignLogByUserId(string email)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignLogs

                         where c.email == email

                         select c;

            return result.ToList();
           
        }

        public static List<CampaignLog> GetCampaignLogByUserId(string email, Guid campaignId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignLogs

                         where c.email == email && c.CampaignId == campaignId

                         select c;

            return result.ToList();
        }
        public static List<CampaignLog> GetCampaignLogByStatusNew()
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CampaignLogs

                         where c.Status == "NEW"

                         select c;

            return result.ToList();


        }
        #endregion
    }
}
