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
Repo.insert! %Tracker.Context {
  title: "Other context",
  context_type: "Context type 2"
}
Enum.each(1..10,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Todo #{x}",
      contexts: [%{ context: context_1, issue_type: "Todo", }]
    }
  end
)
Enum.each(11..20,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Todo #{x}",
      contexts: [%{ context: context_2, issue_type: "Todo", }]
    }
  end
)
