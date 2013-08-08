#!/usr/bin/python



"""TaskMaster API implemented using Google Cloud Endpoints."""

from google.appengine.ext import endpoints
from protorpc import remote

from models import TaskUser
from models import Task
from models import TaskList

from rose_task_api_messages import TaskUserRequestMessage
from rose_task_api_messages import TaskUserResponseMessage
from rose_task_api_messages import TaskResponseMessage
from rose_task_api_messages import TaskListResponseMessage
from rose_task_api_messages import TaskListListRequest
from rose_task_api_messages import TaskListListResponse

import logging

# For https://rose-task.appspot.com
CLIENT_ID = '692785471170.apps.googleusercontent.com';

# For http://localhost:8080
CLIENT_ID_LOCALHOST = '692785471170-eb3d0s8l8mats4knvint6i35977uoojv.apps.googleusercontent.com'

# For my iOS client.  
CLIENT_ID_IOS = '692785471170-iphols9ldsfi4596dn12oc617400d7qc.apps.googleusercontent.com';

@endpoints.api(name='rosetask', version='v1',
               description='Rose Task API',
               allowed_client_ids=[CLIENT_ID, CLIENT_ID_LOCALHOST, CLIENT_ID_IOS, endpoints.API_EXPLORER_CLIENT_ID])
class RoseTaskApi(remote.Service):
    """Class which defines rosetask API v1."""
    
    # ----------------------------- Inserts ----------------------------- 
    @TaskUser.method(user_required=True, path='taskuser', http_method='POST', name='taskuser.insert')
    def task_user_insert(self, a_task_user):
        """ Insert a TaskUser. """
        request_email = a_task_user.lowercase_email.lower()
        current_user_email = endpoints.get_current_user().email().lower()
        if current_user_email != request_email:
            logging.info('Current user email = ' + current_user_email + '  TaskUser email = ' + request_email)            
            #Allow odd creations for testing.  Turn off later as you should only edit yourself.
            raise endpoints.ForbiddenException("Only can only edit/create your own TaskUser.")
        the_task_user = TaskUser.get_task_user_by_email(request_email)
        the_task_user.preferred_name = a_task_user.preferred_name
        the_task_user.google_plus_id = a_task_user.google_plus_id
        if not a_task_user.task_list_keys is None:
            the_task_user.task_list_keys = a_task_user.task_list_keys # TODO: Determine if this will bite you in the butt.
        the_task_user.put()
        return the_task_user
    
    @TaskList.method(user_required=True, path='tasklist', http_method='POST', name='tasklist.insert')
    def task_list_insert(self, a_task_list):
        """ Insert a TaskList. """
        #TODO: Check if current user is in this TaskList
        a_task_list.creator = endpoints.get_current_user()
        a_task_list.task_user_emails.append(endpoints.get_current_user().email().lower())
        if a_task_list.from_datastore:
            logging.info("This is an update not a new TaskList")
            TaskList.flush_task_users(a_task_list.id, a_task_list.task_user_emails)
        else:
            a_task_list.put() # Generate a key because it'll be needed for next steps.
        for an_email in a_task_list.task_user_emails:
            logging.info("Adding " + an_email.lower() + " to the TaskList")
            TaskUser.add_task_list(a_task_list.key, an_email)
        a_task_list.put()
        return a_task_list
    
    
    @Task.method(user_required=True, path='task', http_method='POST', name='task.insert')
    def task_insert(self, a_task):
        """ Insert a Task. """
        #TODO: Check if current user is in this TaskList
        a_task.creator = endpoints.get_current_user()
        parent_task_list = TaskList.get_by_id(a_task.task_list_id)
        a_task.anestor = parent_task_list
        if a_task.assigned_to_email:
            if a_task.assigned_to_email.lower() in parent_task_list.task_user_emails:
                logging.info("Assignment made to " + a_task.assigned_to_email.lower())
            else:
                logging.info("Attempt to assign user that is not in the TaskList. " + a_task.assigned_to_email.lower() + " not found.")
                a_task.assigned_to_email = None
        a_task.put()
        if not a_task.key in parent_task_list.task_keys:
            parent_task_list.task_keys.append(a_task.key)
            parent_task_list.put()
        return a_task


    # ----------------------------- Simple gets ----------------------------- 
    @endpoints.method(TaskUserRequestMessage, TaskUserResponseMessage, path='taskuser', http_method='GET', name='taskuser.get')
    def task_user_get(self, request):
        """ TaskUser get. """
        # Note, OAuth not required.
        an_email = request.lowercase_email.lower()
        a_task_user = TaskUser.get_task_user_by_email(an_email)
        return TaskUserResponseMessage(lowercase_email = a_task_user.lowercase_email,
                                       preferred_name = a_task_user.preferred_name,
                                       google_plus_id = a_task_user.google_plus_id)
    
    @Task.method(user_required=True, request_fields=('id',), path='task/{id}', http_method='GET', name='task.get')
    def task_get(self, a_task):
        """ Task get. """
        #TODO: Check if current user is in this TaskList
        if not a_task.from_datastore:
            raise endpoints.NotFoundException("Task not found.")
        return a_task
    
    @TaskList.method(user_required=True, request_fields=('id',), path='tasklist/{id}', http_method='GET', name='tasklist.get')
    def task_list_get(self, a_task_list):
        """ TaskList get. """
        #TODO: Check if current user is in this TaskList
        if not a_task_list.from_datastore:
            raise endpoints.NotFoundException("TaskList not found.")
        return a_task_list
    
    # ----------------------------- Queries ----------------------------- 
    @endpoints.method(TaskListListRequest, TaskListListResponse, path='tasklist', http_method='GET', name='tasklist.gettasklists')
    def get_task_lists_for_user(self, request):
        """ Returns all the TaskLists for the logged in user. """
        current_user = endpoints.get_current_user()
        if current_user is None:
            raise endpoints.UnauthorizedException('Invalid token.')
        current_users_task_user = TaskUser.get_task_user_by_email(current_user.email().lower())
        users_task_lists = []
        for a_task_list_key in current_users_task_user.task_list_keys:
            a_task_list = a_task_list_key.get()
            all_tasks_in_list = []
            for a_task_key in a_task_list.task_keys:
                a_task = a_task_key.get()
                assigned_to_task_user_msg = None
                if a_task.assigned_to_email:
                    assigned_to_task_user = TaskUser.get_task_user_by_email(a_task.assigned_to_email)
                    assigned_to_task_user_msg = TaskUserResponseMessage(lowercase_email=assigned_to_task_user.lowercase_email, preferred_name=assigned_to_task_user.preferred_name, google_plus_id=assigned_to_task_user.google_plus_id)
                all_tasks_in_list.append(TaskResponseMessage(id=a_task.key.id(),
                                                             text=a_task.text,
                                                             complete=a_task.complete,
                                                             assigned_to=assigned_to_task_user_msg))
            all_task_users_in_list = []
            for a_task_user_email in a_task_list.task_user_emails:
                a_task_user = TaskUser.get_task_user_by_email(a_task_user_email)
                all_task_users_in_list.append(TaskUserResponseMessage(lowercase_email=a_task_user.lowercase_email, preferred_name=a_task_user.preferred_name, google_plus_id=a_task_user.google_plus_id))
            users_task_lists.append(TaskListResponseMessage(id=a_task_list.key.id(), title=a_task_list.title, tasks=all_tasks_in_list, task_users=all_task_users_in_list))
        return TaskListListResponse(items=users_task_lists)
    
    @Task.query_method(user_required=True, query_fields=('task_list_id', 'order', 'pageToken',), path='tasks', name='task.gettasks')
    def task_get_tasks(self, query):
        """ Returns the Tasks that share the task_list_id (ie Tasks that are in the TaskList)"""
        #TODO: Check if current user is in this TaskList
        # This feels poorly done.  It's not using the parent nature NOR the list of Keys in the TaskList. :(
        return query
    
    # ----------------------------- Deletes ----------------------------- 
    @Task.method(user_required=True, request_fields=('id',), path='task/delete/{id}', http_method='GET', name='task.delete')
    def task_delete(self, a_task):
        """ Task Delete. """
        if not a_task.from_datastore:
            raise endpoints.NotFoundException("Task not found.")
        #TODO: Check if current user is in this TaskList
        # Remove the key from the TaskList
        parent_task_list = TaskList.get_by_id(a_task.task_list_id)
        parent_task_list.task_keys.remove(a_task.key)
        parent_task_list.put()
        a_task.key.delete()
        return Task(text="deleted", task_list_id=0)

    @TaskList.method(user_required=True, request_fields=('id',), path='tasklist/delete/{id}', http_method='GET', name='tasklist.delete')
    def TaskListDelete(self, a_task_list):
        """ Delete a TaskList. """
        if not a_task_list.from_datastore:
            raise endpoints.NotFoundException("TaskList not found.")
        #TODO: Check if current user is in this TaskList
        # Delete all the tasks
        for a_task_key in a_task_list.task_keys:
            a_task_key.delete()
        # Remove all the references in the TaskUsers
        TaskList.flush_task_users(a_task_list.id, [])
        a_task_list.key.delete()
        return TaskList(title="deleted")

APPLICATION = endpoints.api_server([RoseTaskApi],
                                   restricted=False)
