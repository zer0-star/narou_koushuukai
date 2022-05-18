record Task {
  name : String,
  priority : Number,
  done : Bool,
  id : String
}

module Task {
  fun setState(value: Bool, task: Task): Task {
    { task | done = value }
  }
}

record TaskView {
  index : Number,
  task : Task
}

module TaskView {
  fun toRow( onChange : Function(TaskView, Bool, Promise(Never, Void))
           , deleteItem : Function(TaskView, Html.Event, Promise(Never, Void))
           , taskView : TaskView)
           : Tuple(String, Array(Ui.Cell)) {
    {
      Number.toString(taskView.index + 1),
      [
        Ui.Cell::Number(taskView.index + 1),
        Ui.Cell::String(taskView.task.name),
        Ui.Cell::Number(taskView.task.priority),
        Ui.Cell::Html(
          <Ui.Checkbox
            checked={taskView.task.done}
            onChange={ onChange(taskView) }/>
        ),
        Ui.Cell::Html(
          <Ui.Button
            iconBefore={Ui.Icons:TRASHCAN}
            type="danger"
            onClick={ deleteItem(taskView) }/>
        )
      ]
    }
  }

  fun sort(by : String, direction : String, tasks : Array(TaskView)) : Array(TaskView) {
    case (by) {
      "index" => tasks |> Array.sortBy((taskView : TaskView) { taskView.index })
      "name" => tasks |> Array.sortBy((taskView : TaskView) { taskView.task.name })
      "priority" => tasks |> Array.sortBy((taskView : TaskView) { -taskView.task.priority })
      => tasks
    } |> Array.reverseIf(direction == "desc")
  }
}

enum Display {
  All
  Done
  NotDone
}

component Works.TodoList {
  state items = [] of Task

  state username = ""

  state display = Display::All

  state newItemText = ""
  state newItemPriorityString = ""
  state newItemPriority = 0
  state newItemErrorMessage = Maybe.nothing()

  state sortColumn = "index"
  state sortDirection = "asc"

  get baseUri {
    "http://naro-todo-server.temma.trap.show/#{username}"
  } 

  fun refresh {
    sequence {
      resp =
        "#{baseUri}/tasks"
        |> Http.get()
        |> Http.send()

      object =
        resp.body
        |> Json.parse()
        |> Maybe.toResult("Json Parse Error")
      
      tasks =
        decode object as Array(Task)
      
      next {
        items = tasks
      }
    } catch Http.ErrorResponse => error {
      next {}
    } catch String => error {
      next {}
    } catch Object.Error => error {
      next {}
    }
  }

  fun selectDisplay(name: String) {
    case (name) {
      "all" => next { display = Display::All }
      "done" => next { display = Display::Done }
      "not-done" => next { display = Display::NotDone }
      => next {}
    }
  }

  fun submit(e: Html.Event) {
    if (newItemText != "") {
      sequence {
        newTask =
          Task(newItemText, newItemPriority, false, Uid.generate())
        
        resp =
          "#{baseUri}/tasks"
          |> Http.post()
          |> Http.jsonBody(encode newTask)
          |> Http.send()

        next {
          items = items |> Array.push(newTask),

          newItemText = "",

          newItemPriorityString = "",

          newItemPriority = 0
        }
      } catch Http.ErrorResponse => error {
        next {}
      }
    } else {
      next {}
    }
  }

  fun onChangePriority (value : String) {
    if (value == "") {
      next {
        newItemPriorityString = "",
        newItemPriority = 0,
        newItemErrorMessage = Maybe.nothing()
      }
    } else {
      try {
        priority = Number.fromString(value)
                  |> Maybe.toResult("Invalid Priority")
        
        next {
          newItemPriorityString = value,
          newItemPriority = priority,
          newItemErrorMessage = Maybe.nothing()
        }
      } catch String => error {
        next {
          newItemPriorityString = value,
          newItemErrorMessage = Maybe.just(error)
        }
      }
    }
  }

  fun toggleItemState(taskView : TaskView, value : Bool) {
    sequence { 
      newTask =
        taskView.task
        |> Task.setState(value)

      resp =
        "#{baseUri}/tasks/#{newTask.id}"
        |> Http.put()
        |> Http.jsonBody(encode newTask)
        |> Http.send()

      next {
        items =
          items
          |> Array.setAt(taskView.index, newTask)
      }
    } catch Http.ErrorResponse => error {
      next {}
    }
  }

  fun deleteItem(taskView : TaskView, e : Html.Event) {
    sequence {
      resp =
        "#{baseUri}/tasks/#{taskView.task.id}"
        |> Http.delete()
        |> Http.send()

      next {
        items =
          items
          |> Array.deleteAt(taskView.index)
      }
    } catch Http.ErrorResponse => error {
      next {}
    }
  }

  get invalidPriority {
    newItemErrorMessage |> Maybe.isJust()
  }

  get rows {
    case (display) {
      Display::All => allRows
      Display::Done => doneRows
      Display::NotDone => notDoneRows
    }
  } where {
    views =
      for (item, i of items) {
        TaskView(i, item)
      }

    allRows =
      views
      |> TaskView.sort(sortColumn, sortDirection)
      |> Array.map(TaskView.toRow(toggleItemState, deleteItem,))

    doneRows =
      views
      |> Array.select((taskView : TaskView) { taskView.task.done })
      |> TaskView.sort(sortColumn, sortDirection)
      |> Array.map(TaskView.toRow(toggleItemState, deleteItem,))

    notDoneRows =
      views
      |> Array.select((taskView : TaskView) { !taskView.task.done })
      |> TaskView.sort(sortColumn, sortDirection)
      |> Array.map(TaskView.toRow(toggleItemState, deleteItem,))
  }

  style table {
    width: 100%;
  }

  fun render : Html {
    <Ui.Column
      gap={Ui.Size::Px(15)}
      align="start">
      <Ui.Row
        align="end"
        gap={Ui.Size::Em(0.5)}>
        <Ui.Field
          label="Your Username">
          <Ui.Input
            value={ username }
            placeholder="Username Here..."
            onChange={ (value : String) { next { username = value }}}/>
        </Ui.Field>
        <Ui.Button
          iconBefore={Ui.Icons:SYNC}
          type="secondary"
          onClick={ (e : Html.Event) { refresh() } }/>
      </Ui.Row>
      <Ui.Field
        label="Display Items">
        <Ui.Select
          value="all"
          onChange={ selectDisplay }
          items=[
            Ui.ListItem::Item(
              content = <{ "All" }>,
              matchString = "all",
              key = "all"
            ),
            Ui.ListItem::Item(
              content = <{ "Done" }>,
              matchString = "done",
              key = "done"
            ),
            Ui.ListItem::Item(
              content = <{ "Not Done" }>,
              matchString = "not done",
              key = "not-done"
            )
          ]/>
      </Ui.Field>
      <Ui.Row
        align="end"
        gap={Ui.Size::Em(0.5)}>
        <Ui.Field
          label="New Task">
          <Ui.Input
            value={ newItemText }
            placeholder="New Item Here..."
            onChange={ (value : String) { next { newItemText = value } } }/>
        </Ui.Field>
        <Ui.Field
          error={ newItemErrorMessage }
          label="Priority">
          <Ui.Input
            value={ newItemPriorityString }
            placeholder="0"
            invalid={ invalidPriority }
            onChange={ onChangePriority }/>
        </Ui.Field>
        <Ui.Button
          label="Submit"
          onClick={ submit }
          disabled={ invalidPriority }
          iconAfter={Ui.Icons:PLUS}/>
      </Ui.Row>
      <div::table>
        <Ui.Table
          bordered={true}
          orderBy={ sortColumn }
          orderDirection={ sortDirection }
          onOrderChange={
            (data : Tuple(String, String)) {
              try {
                {column, direction} = data

                next {
                  sortColumn = column,
                  sortDirection = direction
                }
              }
            }
          }
          headers=[
            {
              sortKey = "index",
              sortable = true,
              label = "#",
              shrink = true
            },
            {
              sortKey = "name",
              sortable = true,
              label = "Name",
              shrink = false
            },
            {
              sortKey = "priority",
              sortable = true,
              label = "Priority",
              shrink = true
            },
            {
              sortKey = "done",
              sortable = false,
              label = "Done",
              shrink = true
            },
            {
              sortKey = "delete",
              sortable = false,
              label = "",
              shrink = true
            }
          ]
          rows={ rows }/>
      </div>
    </Ui.Column>
  }
}