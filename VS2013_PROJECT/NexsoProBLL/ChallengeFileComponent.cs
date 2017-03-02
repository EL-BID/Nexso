using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;

namespace NexsoProBLL
{
    public class ChallengeFileComponent
    {

        private ChallengeFile challengeFile;
        private MIFNEXSOEntities mifnexsoEntities;

        public ChallengeFile ChallengeFile
        {
            get { return challengeFile; }
        }

        public ChallengeFileComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            challengeFile = new ChallengeFile();
            challengeFile.ChallengeObjectId = Guid.Empty;
            challengeFile.ChallengeReferenceId = string.Empty;
            mifnexsoEntities.ChallengeFiles.AddObject(challengeFile);
        }

        public ChallengeFileComponent(Guid challengeObjectId)
        {
            if (challengeObjectId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    challengeFile = mifnexsoEntities.ChallengeFiles.FirstOrDefault(a => a.ChallengeObjectId == challengeObjectId);
                    if (challengeFile == null)
                    {
                        challengeFile = new ChallengeFile();
                        challengeFile.ChallengeObjectId = Guid.Empty;
                        challengeFile.ChallengeReferenceId = string.Empty;
                        mifnexsoEntities.ChallengeFiles.AddObject(challengeFile);
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
                if (challengeFile.ChallengeObjectId == Guid.Empty)
                    challengeFile.ChallengeObjectId = Guid.NewGuid();
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {
                throw;
                //return -1;
            }
        }

        public int Delete()
        {
            try
            {
                mifnexsoEntities.DeleteObject(challengeFile);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = challengeFile.EntityState;
            if (challengeFile.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(challengeFile);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.ChallengeFiles.AddObject(challengeFile);
                else
                    mifnexsoEntities.ChallengeFiles.Attach(challengeFile);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }


        public static List<ChallengeFile> GetFilesForChallenge(string challengeReference, string objectType)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.ChallengeFiles
                         where c.ChallengeReferenceId == challengeReference && c.ObjectType == objectType

                         select c;

            return result.ToList();
        }

    }
}