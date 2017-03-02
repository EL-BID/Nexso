using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{

   public class MailTrackerLogComponent
    {

        private MailTrackerLog mailTrackerLog;
        private MIFNEXSOEntities mifnexsoEntities;

        public MailTrackerLog MailTrackerLog
        {
            get { return mailTrackerLog; }
        }


        public MailTrackerLogComponent(Guid mailTrackerLogId)
        {
            if (mailTrackerLogId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {


                    mailTrackerLog = mifnexsoEntities.MailTrackerLogs.FirstOrDefault(a => a.MailTrackerLogId == mailTrackerLogId);


                    if (mailTrackerLog == null)
                    {
                        mailTrackerLog = new MailTrackerLog();
                        mailTrackerLog.MailTrackerLogId = Guid.Empty;

                        mifnexsoEntities.MailTrackerLogs.AddObject(mailTrackerLog);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
            else
            {
                mailTrackerLog = new MailTrackerLog();
            }
        }



        public MailTrackerLogComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            mailTrackerLog = new MailTrackerLog();
            mailTrackerLog.MailTrackerLogId = Guid.Empty;

            mifnexsoEntities.MailTrackerLogs.AddObject(mailTrackerLog);

        }

        public int Save()
        {
            try
            {
                if (mailTrackerLog.MailTrackerLogId == Guid.Empty)
                    mailTrackerLog.MailTrackerLogId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(mailTrackerLog);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = mailTrackerLog.EntityState;
            if (mailTrackerLog.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(mailTrackerLog);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.MailTrackerLogs.AddObject(mailTrackerLog);
                else
                    mifnexsoEntities.MailTrackerLogs.Attach(mailTrackerLog);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


    }
}
