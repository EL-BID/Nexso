using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;
namespace NexsoProBLL
{
    public class ChallengeCustomDataComponent
    {
        private ChallengeCustomData challengeCustomData;
        private MIFNEXSOEntities mifnexsoEntities;

        public ChallengeCustomData ChallengeCustomData
        {
            get { return challengeCustomData; }
        }

        public ChallengeCustomDataComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            challengeCustomData = new ChallengeCustomData();
            challengeCustomData.ChallengeCustomDatalId = Guid.Empty;
            challengeCustomData.ChallengeReference = string.Empty;
            mifnexsoEntities.ChallengeCustomData.AddObject(challengeCustomData);
        }

        public ChallengeCustomDataComponent(Guid challengeCustomDataId)
        {
            if (challengeCustomDataId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengeCustomData = mifnexsoEntities.ChallengeCustomData.FirstOrDefault(a => a.ChallengeCustomDatalId == challengeCustomDataId);
                    if (challengeCustomData == null)
                    {
                        challengeCustomData = new ChallengeCustomData();
                        challengeCustomData.ChallengeCustomDatalId = Guid.Empty;
                        challengeCustomData.ChallengeReference = string.Empty;
                        mifnexsoEntities.ChallengeCustomData.AddObject(challengeCustomData);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }
        public ChallengeCustomDataComponent(string customDataTemplate)
        {
            if (customDataTemplate != null)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengeCustomData = mifnexsoEntities.ChallengeCustomData.FirstOrDefault(a => a.CustomDataTemplate == customDataTemplate);
                    if (challengeCustomData == null)
                    {
                        challengeCustomData = new ChallengeCustomData();
                        challengeCustomData.ChallengeCustomDatalId = Guid.Empty;
                        challengeCustomData.ChallengeReference = string.Empty;
                        mifnexsoEntities.ChallengeCustomData.AddObject(challengeCustomData);
                    }

                }
                catch (Exception)
                {
                    throw;
                }
            }
        }

        public ChallengeCustomDataComponent(string challengeReference, string language)
        {
            if (challengeReference != string.Empty && language != string.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengeCustomData = mifnexsoEntities.ChallengeCustomData.FirstOrDefault(a => a.ChallengeReference == challengeReference && a.Language == language);
                    if (challengeCustomData == null)
                    {
                        challengeCustomData = new ChallengeCustomData();
                        challengeCustomData.ChallengeCustomDatalId = Guid.Empty;
                        challengeCustomData.ChallengeReference = string.Empty;
                        mifnexsoEntities.ChallengeCustomData.AddObject(challengeCustomData);
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
                if (challengeCustomData.ChallengeCustomDatalId == Guid.Empty)
                    challengeCustomData.ChallengeCustomDatalId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(challengeCustomData);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = challengeCustomData.EntityState;
            if (challengeCustomData.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(challengeCustomData);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.ChallengeCustomData.AddObject(challengeCustomData);
                else
                    mifnexsoEntities.ChallengeCustomData.Attach(challengeCustomData);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        
    }
}
