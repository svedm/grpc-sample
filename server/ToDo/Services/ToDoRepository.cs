using System;
using System.Collections.Generic;
using System.Linq;

namespace ToDo.Services
{
    public class ToDoRepository
    {
        private readonly IList<ToDoItem> _items;

        public ToDoRepository()
        {
            _items = new List<ToDoItem>
            {
                new ToDoItem
                {
                    Id = Guid.NewGuid().ToString(),
                    Text = "Say hello"
                }
            };
        }

        public IEnumerable<ToDoItem> All()
        {
            return _items;
        }

        public ToDoItem Add(string newTask)
        {
            var item = new ToDoItem
            {
                Id = Guid.NewGuid().ToString(),
                Text = newTask
            };
            _items.Add(item);
            return item;
        }

        public ToDoItem Remove(string id)
        {
            var item = _items.First(s => s.Id == id);
            _items.Remove(item);
            return item;
        }
    }
}