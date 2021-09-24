alias Cometoid.Repo
alias Cometoid.Model.Tracker

context_1 = Repo.insert! %Tracker.Context {
  title: "Todolist 1",
  context_type: "Todolist"
}
context_2 = Repo.insert! %Tracker.Context {
  title: "Todolist 2",
  context_type: "Todolist"
}
Enum.each(1..10,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Todo #{x}",
      issue_type: "Todo",
      contexts: [context_1]
    }
  end
)
Enum.each(11..20,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Todo #{x}",
      issue_type: "Todo",
      contexts: [context_2]
    }
  end
)
