using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;

namespace NexsoProBLL
{
    public class ChallengePageComponent
    {

        private ChallengePage challengePage;
        private MIFNEXSOEntities mifnexsoEntities;

        public ChallengePage ChallengePage
        {
            get { return challengePage; }
        }

        public ChallengePageComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            challengePage = new ChallengePage();
            challengePage.ChallengePageId = Guid.Empty;
            challengePage.ChallengeCustomDataId = Guid.Empty;
            mifnexsoEntities.ChallengePages.AddObject(challengePage);
        }

        public ChallengePageComponent(Guid challengePageId)
        {
            if (challengePageId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengePage = mifnexsoEntities.ChallengePages.FirstOrDefault(a => a.ChallengePageId == challengePageId);
                    if (challengePage == null)
                    {
                        challengePage = new ChallengePage();
                        challengePage.ChallengePageId = Guid.Empty;
                        challengePage.ChallengeCustomDataId = Guid.Empty;
                        mifnexsoEntities.ChallengePages.AddObject(challengePage);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }
       
        /// <summary>
        /// Load Pages per Challenge Reference
        /// </summary>
        /// <param name="challengeCustomDataId"></param>
        /// <param name="reference"></param>
        public ChallengePageComponent(Guid challengeCustomDataId, string reference)
        {
            if (challengeCustomDataId != Guid.Empty && !string.IsNullOrEmpty(reference))
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengePage = mifnexsoEntities.ChallengePages.FirstOrDefault(a => a.ChallengeCustomDataId == challengeCustomDataId && a.Reference == reference);
                    if (challengePage == null)
                    {
                        challengePage = new ChallengePage();
                        challengePage.ChallengePageId = Guid.Empty;
                        challengePage.ChallengeCustomDataId = Guid.Empty;
                        mifnexsoEntities.ChallengePages.AddObject(challengePage);
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
                if (challengePage.ChallengePageId == Guid.Empty)
                    challengePage.ChallengePageId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(challengePage);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = challengePage.EntityState;
            if (challengePage.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(challengePage);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.ChallengePages.AddObject(challengePage);
                else
                    mifnexsoEntities.ChallengePages.Attach(challengePage);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        public static List<ChallengePage> GetPagesForCustomData(Guid customDataId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.ChallengePages
                         where c.ChallengeCustomDataId == customDataId 


                         select c;

            return result.ToList();
        }

    }
}
