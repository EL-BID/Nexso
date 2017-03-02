using System;
using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class SolutionLogComponent
    {
        private SolutionLog solutionLog;
        private MIFNEXSOEntities mifnexsoEntities;

        public SolutionLog SolutionLog
        {
            get { return solutionLog; }
        }

        public SolutionLogComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            solutionLog = new SolutionLog();
            solutionLog.SolutionLogId = Guid.Empty;
            solutionLog.SolutionId = Guid.NewGuid();
            mifnexsoEntities.SolutionLogs.AddObject(solutionLog);
        }

        public SolutionLogComponent(Guid solutionLogId)
        {
            if (solutionLogId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    solutionLog = mifnexsoEntities.SolutionLogs.FirstOrDefault(a => a.SolutionLogId == solutionLogId);
                    if (solutionLog == null)
                    {
                        solutionLog = new SolutionLog();
                        solutionLog.SolutionLogId = Guid.Empty;
                        mifnexsoEntities.SolutionLogs.AddObject(solutionLog);
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
                if (solutionLog.SolutionLogId == Guid.Empty)
                    solutionLog.SolutionLogId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(solutionLog);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = solutionLog.EntityState;
            if (solutionLog.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(solutionLog);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.SolutionLogs.AddObject(solutionLog);
                else
                    mifnexsoEntities.SolutionLogs.Attach(solutionLog);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        #region Static Methods
        public static IQueryable<SolutionLog> GetLogs(Guid solutionId, string key)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionLogs
                         where c.SolutionId == solutionId && c.Key == key
                         select c;

            return result;

        }

        #endregion
    }
}
