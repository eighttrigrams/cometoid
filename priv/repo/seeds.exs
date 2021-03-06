alias Cometoid.Repo
alias Cometoid.Model.Tracker

software_task = Repo.insert! %Tracker.Context {
  title: "Task",
  view: "Software"
}
my_software_component = Repo.insert! %Tracker.Context {
  title: "MySoftwareComponent",
  view: "Software",
  secondary_contexts: [software_task]
}
my_software_project = Repo.insert! %Tracker.Context {
  title: "MySoftwareProject",
  view: "Software",
  secondary_contexts: [my_software_component, software_task]
}
Enum.each(1..5,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Task #{x}",
      contexts: [%{ context: my_software_project },
                 %{ context: software_task }]
    }
  end
)
Enum.each(1..5,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "ComponentTask #{x}",
      contexts: [%{ context: my_software_component },
                 %{ context: software_task }]
    }
  end
)
Enum.each(1..5,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Issue #{x}",
      contexts: [%{ context: my_software_project }]
    }
  end
)
Enum.each(1..5,
  fn x ->
    Repo.insert! %Tracker.Issue {
      title: "Issue #{x}",
      contexts: [%{ context: my_software_component },
                 %{ context: my_software_project }]
    }
  end
)
