record Task {
  name : String,
  done : Bool
}

module Task {
  fun setState(value: Bool, task: Task): Task {
    { task | done = value }
  }

  fun toRow( task : Task
           , index : Number
           , onChange : Function(Bool, Promise(Never, Void))
           , deleteItem : Function(Html.Event, Promise(Never, Void)))
           : Tuple(String, Array(Ui.Cell)) {
    {
      Number.toString(index),
      [
        Ui.Cell::Number(index),
        Ui.Cell::String(task.name),
        Ui.Cell::Html(
          <Ui.Checkbox
            checked={task.done}
            onChange={ onChange }/>
        ),
        Ui.Cell::Html(
          <Ui.Button
            iconBefore={Ui.Icons:TRASHCAN}
            type="danger"
            onClick={ deleteItem }/>
        )
      ]
    }
  }
}

enum Display {
  All
  Done
  NotDone
}

component Works.TodoList {
  state items = [] of Task

  state display = Display::All

  state newItemText = ""

  state sortColumn = "index"
  state sortDirection = "desc"

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
      next {
        items = items |> Array.push(Task(newItemText, false)),

        newItemText = ""
      }
    } else {
      next {}
    }
  }

  fun onChange(index: Number, value: Bool) {
    next {
      items = items |> Array.updateAt(index, Task.setState(value))
    }
  }

  fun deleteItem(index : Number, e : Html.Event) {
    next {
      items = items |> Array.deleteAt(index)
    }
  }

  get rows {
    case (display) {
      Display::All => allRows
      Display::Done => doneRows
      Display::NotDone => notDoneRows
    }
  } where {
    allViews =
      for (item, i of items) {
        { item.done, Task.toRow(item, i + 1, onChange(i), deleteItem(i)) }
      }

    allRows =
      for (view of allViews) {
        try {
          {done, row} = view

          row
        }
      }

    doneRows =
      for (view of allViews) {
        try {
          {done, row} = view

          row
        }
      } when {
        try {
          {done, row} = view

          done
        }
      }    

    notDoneRows =
      for (view of allViews) {
        try {
          {done, row} = view

          row
        }
      } when {
        try {
          {done, row} = view

          !done
        }
      }    
  }

  style table {
    width: 100%;
  }

  fun render : Html {
    <Ui.Column
      align="start">
      <Ui.Row
        align="end"
        gap={Ui.Size::Em(1.5)}>
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
        <Ui.Field
          label="New Item">
          <Ui.Input
            value={ newItemText }
            placeholder="New Item Here..."
            onChange={ (value : String) { next { newItemText = value } } }/>
        </Ui.Field>
        <Ui.Button
          label="Submit"
          onClick={ submit }
          iconAfter={Ui.Icons:PLUS}/>
      </Ui.Row>
      <div::table>
        <Ui.Table
          bordered={true}
          orderBy={ sortColumn }
          orderDirection={ sortDirection }
          headers=[
            {
              sortKey = "index",
              sortable = true,
              label = "#",
              shrink = true
            },
            {
              sortKey = "name",
              sortable = false,
              label = "Name",
              shrink = false
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