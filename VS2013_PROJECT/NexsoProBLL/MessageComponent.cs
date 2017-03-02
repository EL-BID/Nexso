using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NexsoProDAL;
using System.Data;

namespace NexsoProBLL
{
    public class MessageComponent
    {
        private Message message;
        private MIFNEXSOEntities mifnexsoEntities;

        public Message Message
        {
            get { return message; }
        }



        public MessageComponent()
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            message = new Message();
            message.MessageId = Guid.Empty;
            mifnexsoEntities.Messages.AddObject(message);
        }

        public MessageComponent(Guid guid)
        {
            mifnexsoEntities = new MIFNEXSOEntities();
            try
            {
                if (guid != Guid.Empty)
                {
                    message = mifnexsoEntities.Messages.FirstOrDefault(a => a.MessageId == guid);
                }
                else
                {
                    message = new Message();
                    message.MessageId = Guid.Empty;
                    mifnexsoEntities.Messages.AddObject(message);
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
                if (message.MessageId == Guid.Empty)
                    message.MessageId = Guid.NewGuid();
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
                mifnexsoEntities.DeleteObject(message);
                return mifnexsoEntities.SaveChanges();
            }
            catch (Exception)
            {

                return -1;
            }

        }

        public void ChangeContext(ref MIFNEXSOEntities mifnexsoEntities)
        {
            EntityState entityState = message.EntityState;
            if (message.EntityState != EntityState.Detached)
            {
                this.mifnexsoEntities.Detach(message);
                if (entityState == EntityState.Added)
                    mifnexsoEntities.Messages.AddObject(message);
                else
                    mifnexsoEntities.Messages.Attach(message);

            }
            this.mifnexsoEntities.Dispose();
            this.mifnexsoEntities = mifnexsoEntities;
        }

        #region Static Methods
        public static IQueryable<Message> GetMessagesFrom(int fromUserId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Messages
                         where c.FromUserId == fromUserId
                         select c;

            return result;

        }

        public static IQueryable<Message> GetMessagesTo(int toUserId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Messages
                         where c.ToUserId == toUserId
                         select c;

            return result;

        }

        public static IQueryable<Message> GetMessages(int toUserId, int fromUserId)
        {
            var mifnexsoEntities = new MIFNEXSOEntities();
            var result = from c in mifnexsoEntities.Messages
                         where c.ToUserId == toUserId && c.FromUserId == fromUserId
                         select c;

            return result;

        }

        #endregion

    }
}
