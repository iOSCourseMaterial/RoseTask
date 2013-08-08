""" Model classes for the RoseTask API """


from google.appengine.ext import endpoints
from google.appengine.ext import ndb
from endpoints_proto_datastore.ndb import EndpointsModel

import logging

TIME_FORMAT_STRING = '%b %d, %Y %I:%M:%S %p'


def get_endpoints_current_user(raise_unauthorized=True):
    """Returns a current user and (optionally) causes an HTTP 401 if no user.

    Args:
        raise_unauthorized: Boolean; defaults to True. If True, this method
            raises an exception which causes an HTTP 401 Unauthorized to be
            returned with the request.

    Returns:
        The signed in user if there is one, else None if there is no signed in
        user and raise_unauthorized is False.
    """
    current_user = endpoints.get_current_user()
    if raise_unauthorized and current_user is None:
        raise endpoints.UnauthorizedException('Invalid token.')
    return current_user

class TaskUser(EndpointsModel):
    """ Model that represents an individual user. """
    _message_fields_schema = ('id', 'entityKey', 'lowercase_email', 'preferred_name', 'google_plus_id', 'task_list_ids')
    lowercase_email = ndb.StringProperty(required=True) # Also using lowercase_email as the entity key name
    preferred_name = ndb.StringProperty()
    google_plus_id = ndb.StringProperty(required=False)
    task_list_ids = ndb.IntegerProperty(repeated=True) # Used to work around PD
    created = ndb.DateTimeProperty(auto_now=True)
    # Consider adding a blob property for the image.
    
    @property
    def timestamp(self):
        return self.created.strftime(TIME_FORMAT_STRING)

    @classmethod
    def get_task_user_by_email(cls, an_email):
        an_email = an_email.lower() # Just in case.
        query = cls.query(cls.lowercase_email == an_email)
        # Create a new TaskUser for this email if none exist
        if query.count() == 0:
            new_task_user = TaskUser(lowercase_email = an_email)
            return new_task_user
        else:
            for the_task_user in query:
                return the_task_user

    def get_all_task_lists_for_user(self):
        task_lists = []
        query = TaskList.query_for_task_user(self.entityKey())
        for atasklist in query:
            task_lists.append(atasklist)
        return task_lists
        
class Task(EndpointsModel):
    """ Model to store a single task"""
    _message_fields_schema = ('id', 'entityKey', 'text', 'complete', 'assigned_to_email', 'task_list_id', 'created')
    text = ndb.StringProperty(required=True)
    complete = ndb.BooleanProperty(default=False)
    assigned_to = ndb.KeyProperty(kind=TaskUser) # Not sure which to keep
    assigned_to_email = ndb.StringProperty() 
    task_list_id = ndb.IntegerProperty() # Used to work around PD
    created = ndb.DateTimeProperty(auto_now=True)
    creator = ndb.UserProperty(required=False)
    
    @property
    def timestamp(self):
        return self.created.strftime(TIME_FORMAT_STRING)
    
#     #Using the repeated key property for Tasks instead.
#     @classmethod
#     def query_task_list(cls, ancestor_key):
#         return cls.query(ancestor=ancestor_key).order(-cls.created)
    
class TaskList(EndpointsModel):
    """ Model to store a lists of task and list of users"""
    _message_fields_schema = ('id', 'entityKey', 'title', 'tasks', 'task_users', 'task_users_emails')
    title = ndb.StringProperty(required=True)
    tasks = ndb.KeyProperty(kind=Task,repeated=True)
    task_users = ndb.KeyProperty(kind=TaskUser,repeated=True)
    task_users_emails = ndb.StringProperty(repeated=True) # Used to work around passing in a key in PD.  Used to pass info, *NOT* updated!
    created = ndb.DateTimeProperty(auto_now_add=True)
    creator = ndb.UserProperty(required=False)
    
    @property
    def timestamp(self):
        return self.created.strftime(TIME_FORMAT_STRING)
    
#     #This approach used the parent relationship,  Instead I'm using the repeated key property for getting Tasks instead.
#     def get_all_tasks(self):
#         taskListTasks = []
#         query = Task.query_task_list(self.entityKey())
#         for atask in query:
#             taskListTasks.append(atask)
#         return taskListTasks

    def flush_task_users_list(self):
        # Remove their reference to the TaskList
        for a_task_user_key in self.task_users:
            logging.info("Removing " + str(self.key.id()) + " from " + str(a_task_user_key))
            a_task_user = a_task_user_key.get()
            if self.key.id() in a_task_user.task_list_ids:
                logging.info("Found that TaskList id as expected.")
            else:
                logging.info("Did NOT find the id " + str(self.key.id()))
            a_task_user.task_list_ids.remove(self.key.id())
            a_task_user.put()
        self.task_users = []
        
    def add_task_user_by_email(self, an_email):
        task_user_for_email = TaskUser.get_task_user_by_email(an_email)
        if not task_user_for_email in self.task_users:
            self.task_users.append(task_user_for_email.key)
            # Add this list to the TaskUser ids as well
            task_user_for_email.task_list_ids.append(self.key.id())
            task_user_for_email.put()
        
    def get_all_tasks(self):
        taskListTasks = []
        for task_key in self.tasks:
            taskListTasks.append(task_key.get())
        return taskListTasks
    
    def get_all_task_users(self):
        taskUsers = []
        for task_user_key in self.task_users:
            taskUsers.append(task_user_key.get())
        return taskUsers
    
    @classmethod
    def query_for_task_user(cls, task_user_key):
        return cls.query(cls.task_users == task_user_key).order(-cls.created)
    
    