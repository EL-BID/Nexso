using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;
namespace NexsoProBLL
{
    public class ChallengeJudgeComponent
    {
        private ChallengeJudge challengeJudge;
        private MIFNEXSOEntities mifnexsoEntities;

        public ChallengeJudge ChallengeJudge
        {
            get { return challengeJudge; }
        }

        public ChallengeJudgeComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            challengeJudge = new ChallengeJudge();
            challengeJudge.ChallengeJudgeId = Guid.Empty;
            mifnexsoEntities.ChallengeJudges.AddObject(challengeJudge);
        }

        public ChallengeJudgeComponent(Guid ChallengeJudgeId)
        {
            if (ChallengeJudgeId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengeJudge = mifnexsoEntities.ChallengeJudges.FirstOrDefault(a => a.ChallengeJudgeId == ChallengeJudgeId);
                    if (challengeJudge == null)
                    {
                        challengeJudge = new ChallengeJudge();
                        challengeJudge.ChallengeJudgeId = Guid.Empty;
                        mifnexsoEntities.ChallengeJudges.AddObject(challengeJudge);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }
        public ChallengeJudgeComponent(int userId, string challengeReference)
        {
            if (challengeReference!=null)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengeJudge = mifnexsoEntities.ChallengeJudges.FirstOrDefault(a => a.UserId == userId && a.ChallengeReference == challengeReference);
                    if (challengeJudge == null)
                    {
                        challengeJudge = new ChallengeJudge();
                        challengeJudge.ChallengeJudgeId = Guid.Empty;
                        mifnexsoEntities.ChallengeJudges.AddObject(challengeJudge);
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
                if (challengeJudge.ChallengeJudgeId == Guid.Empty)
                    challengeJudge.ChallengeJudgeId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(challengeJudge);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = challengeJudge.EntityState;
            if (challengeJudge.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(challengeJudge);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.ChallengeJudges.AddObject(challengeJudge);
                else
                    mifnexsoEntities.ChallengeJudges.Attach(challengeJudge);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region
        
        public static List<ChallengeJudge> GetChallengeJudges(string challengeReference)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.ChallengeJudges

                         where c.ChallengeReference == challengeReference

                         select c;

            return result.ToList();
            
        }

        #endregion

    }
}
