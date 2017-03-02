
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using NexsoProDAL;

namespace NexsoProBLL
{
    public class SolutionCommentComponent
    {
        private SolutionComment solutionComment;
        private MIFNEXSOEntities mifnexsoEntities;

        public SolutionComment SolutionComment
        {
            get { return solutionComment; }
        }



        public SolutionCommentComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            solutionComment = new SolutionComment();
            solutionComment.Comment_Id = Guid.Empty;
            solutionComment.SolutionId = Guid.Empty;
            mifnexsoEntities.SolutionComments.AddObject(solutionComment);
        }

        public SolutionCommentComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    solutionComment = mifnexsoEntities.SolutionComments.FirstOrDefault(a => a.Comment_Id == guid);
                }
                else
                {
                    solutionComment = new SolutionComment();
                    solutionComment.SolutionId = Guid.Empty;
                    solutionComment.Comment_Id = Guid.Empty;
                    mifnexsoEntities.SolutionComments.AddObject(solutionComment);
                }
            }
            catch (Exception)
            {
                throw;
            }
        }

        public int Save()
        {
            try
            {
                if (solutionComment.Comment_Id == Guid.Empty)
                    solutionComment.Comment_Id = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(solutionComment);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }



        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = solutionComment.EntityState;
            if (solutionComment.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(solutionComment);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.SolutionComments.AddObject(solutionComment);
                else
                    mifnexsoEntities.SolutionComments.Attach(solutionComment);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region Static Methods

        public static IQueryable<SolutionComment> GetCommentsPerSolution(Guid solutionId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionComments
                         where c.SolutionId == solutionId
                         select c;

            return result;



        }
        public static IQueryable<SolutionComment> GetCommentsPerSolution(Guid solutionId, string scope)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.SolutionComments
                         where c.SolutionId == solutionId && c.Scope == scope
                         select c;

            return result;



        }

        //public static IQueryable<Solution> GetDraftSolutionPerOrganization(Guid organizationId)
        //{
        //    var mifnexsoEntities = new MIFNEXSOEntities();
        //    var result = from c in mifnexsoEntities.Solution
        //                 join o in mifnexsoEntities.Organization
        //                 on c.OrganizationId equals o.OrganizationID
        //                 where o.OrganizationID == organizationId && c.SolutionState<1000
        //                 select c;

        //    return result;



        //}

        //public static IQueryable<Solution> GetSolutionPerUser(int userId)
        //{
        //    var mifnexsoEntities = new MIFNEXSOEntities();
        //    var result = from c in mifnexsoEntities.Solution
        //                 join o in mifnexsoEntities.Organization
        //                     on c.OrganizationId equals o.OrganizationID
        //                 join z in mifnexsoEntities.UserOrganization
        //                     on o.OrganizationID equals z.OrganizationID
        //                 where z.UserID == userId & c.SolutionState == 1000 

        //                 select c;

        //    return result;



        //}

        //public static IQueryable<Solution> GetDraftSolutionPerUser(int userId)
        //{
        //    var mifnexsoEntities = new MIFNEXSOEntities();
        //    var result = from c in mifnexsoEntities.Solution
        //                 join o in mifnexsoEntities.Organization
        //                     on c.OrganizationId equals o.OrganizationID
        //                 join z in mifnexsoEntities.UserOrganization
        //                     on o.OrganizationID equals z.OrganizationID
        //                 where z.UserID == userId & c.SolutionState < 1000 

        //                 select c;

        //    return result;



        //}

        #endregion
    }
}
