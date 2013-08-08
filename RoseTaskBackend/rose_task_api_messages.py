
from protorpc import messages

class TaskUserResponseMessage(messages.Message):
    lowercase_email = messages.StringField(1)
    preferred_name = messages.StringField(2)
    google_plus_id = messages.StringField(3)
    
class TaskResponseMessage(messages.Message):
    id = messages.IntegerField(1)
    text = messages.StringField(2)
    complete = messages.BooleanField(3)
    assigned_to = messages.MessageField(TaskUserResponseMessage, 4)
    
class TaskListResponseMessage(messages.Message):
    id = messages.IntegerField(1)
    title = messages.StringField(2)
    tasks = messages.MessageField(TaskResponseMessage, 3, repeated = True)
    task_users = messages.MessageField(TaskUserResponseMessage, 4, repeated = True)

class TaskListListRequest(messages.Message):
    """ProtoRPC message definition to represent a tasklist query."""
    limit = messages.IntegerField(1, default=20)
    class Order(messages.Enum):
        WHEN = 1
        TITLE = 2
    order = messages.EnumField(Order, 2, default=Order.WHEN)
    
class TaskListListResponse(messages.Message):
    """ProtoRPC message definition to represent a list of task lists."""
    items = messages.MessageField(TaskListResponseMessage, 1, repeated=True)