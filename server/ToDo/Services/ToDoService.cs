using System.Threading.Tasks;
using Grpc.Core;

namespace ToDo.Services
{
    public class ToDoService: ToDo.ToDoService.ToDoServiceBase
    {
        private readonly ToDoRepository _repository;

        public ToDoService(ToDoRepository repository)
        {
            _repository = repository;
        }

        public override Task<ListResponse> List(Empty request, ServerCallContext context)
        {
            var response = new ListResponse();
            response.Items.AddRange(_repository.All());
            return Task.FromResult(response);
        }

        public override Task<ToDoItem> Add(AddRequest request, ServerCallContext context)
        {
            if (request.Text.Length == 0)
            {
                throw new RpcException(new Status(StatusCode.InvalidArgument,"Text shouldn't be empty"));
            }
            return Task.FromResult(_repository.Add(request.Text));
        }

        public override Task<ToDoItem> Remove(RemoveRequest request, ServerCallContext context)
        {
            var result = _repository.Remove(request.Id);
            if (result == null)
            {
                throw new RpcException(new Status(StatusCode.NotFound, "Task not found"));
            }
            return Task.FromResult(result);
        }
    }
}