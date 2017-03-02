using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class JudgesAssignationComponent
    {
        private JudgesAssignation judgesAssignation;
        private MIFNEXSOEntities mifnexsoEntities;

        public JudgesAssignation JudgesAssignation
        {
            get { return judgesAssignation; }
        }

        public JudgesAssignationComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            judgesAssignation = new JudgesAssignation();
            judgesAssignation.JudgeAssigantionId = Guid.Empty;
            mifnexsoEntities.JudgesAssignations.AddObject(judgesAssignation);
        }

        public JudgesAssignationComponent(Guid judgeAssigantionId)
        {
            if (judgeAssigantionId != Guid.Empty)
            {
                mifnexsoEntities = new MIFNEXSOEntities();
                try
                {

                    judgesAssignation = mifnexsoEntities.JudgesAssignations.FirstOrDefault(a => a.JudgeAssigantionId == judgeAssigantionId);
                    if (judgesAssignation == null)
                    {
                        judgesAssignation = new JudgesAssignation();
                        judgesAssignation.JudgeAssigantionId = Guid.Empty;
                        mifnexsoEntities.JudgesAssignations.AddObject(judgesAssignation);
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
                mifnexsoEntities.DeleteObject(judgesAssignation);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = judgesAssignation.EntityState;
            if (judgesAssignation.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(judgesAssignation);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.JudgesAssignations.AddObject(judgesAssignation);
                else
                    mifnexsoEntities.JudgesAssignations.Attach(judgesAssignation);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        public static bool deleteListPerChallengeJudgeId(Guid challengeJudgeId)
        {
            try
            {
                var mifnexsoEntities = new MIFNEXSOEntities();
                int results = mifnexsoEntities.ExecuteStoreCommand(
                     string.Format("DELETE JUDGESASSIGNATION WHERE ChallengeJudgeId='{0}'", challengeJudgeId.ToString()));

                return true;
            }
            catch (Exception)
            {
                return false;
            }




        }
        public static List<JudgesAssignation> GetJudgesPerSolution(Guid solutionId, string challengeReference)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.JudgesAssignations

                         where c.SolutionId == solutionId && c.ChallengeJudge.ChallengeReference == challengeReference

                         select c;

            return result.ToList();

        }
        public static List<JudgesAssignation> GetJudgesPerSolution(Guid solutionId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.JudgesAssignations

                         where c.SolutionId == solutionId 

                         select c;

            return result.ToList();

        }
    }
}
