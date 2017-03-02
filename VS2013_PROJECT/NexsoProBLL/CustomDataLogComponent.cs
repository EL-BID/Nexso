using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;
namespace NexsoProBLL
{
    public class CustomDataLogComponent
    {
        private CustomDataLog customDataLog;
        private MIFNEXSOEntities mifnexsoEntities;

        public CustomDataLog CustomDataLog
        {
            get { return customDataLog; }
        }

        public CustomDataLogComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            customDataLog = new CustomDataLog();
            customDataLog.CustomDataLogId = Guid.Empty;
            mifnexsoEntities.CustomDataLog.AddObject(customDataLog);
        }

        public CustomDataLogComponent(Guid customDataLogId)
        {
            if (customDataLogId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    customDataLog = mifnexsoEntities.CustomDataLog.FirstOrDefault(a => a.CustomDataLogId == customDataLogId);
                    if (customDataLog == null)
                    {
                        customDataLog = new CustomDataLog();
                        customDataLog.CustomDataLogId = Guid.Empty;
                        mifnexsoEntities.CustomDataLog.AddObject(customDataLog);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }


        public int Save()
        {
            try
            {
                if (customDataLog.CustomDataLogId == Guid.Empty)
                    customDataLog.CustomDataLogId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(customDataLog);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = customDataLog.EntityState;
            if (customDataLog.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(customDataLog);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.CustomDataLog.AddObject(customDataLog);
                else
                    mifnexsoEntities.CustomDataLog.Attach(customDataLog);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static IQueryable<CustomDataLog> GetCustomDataLogs(Guid solutionId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.CustomDataLog

                         where c.SolutionId == solutionId
                         orderby c.Created descending
                         select c;

            return result;
        }
    }
}
