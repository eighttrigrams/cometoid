defmodule Cometoid.Editor do

  alias Cometoid.CodeAdapter

  def open_event event do
    [path, title, type, id] = if is_nil(event.issue) do
      id = Integer.to_string(event.id)
      [
        Application.fetch_env!(:cometoid, :data_path) <> "event_"<> id <> ".md",
        event.title,
        "Event",
        id
      ]
    else
      id = Integer.to_string(event.issue.id)
      [
        Application.fetch_env!(:cometoid, :data_path) <> "issue_"<> id <> ".md",
        event.issue.title,
        "Issue",
        id
      ]
    end
    CodeAdapter.open_in_editor(path, id, type, title)
  end

  def delete_event event do
    id = Integer.to_string(event.id)
    path = Application.fetch_env!(:cometoid, :data_path) <> "event_"<> id <> ".md"
    CodeAdapter.delete path
  end

  def open_context context do

    case context.context_type do
      "Person" ->
        id = Integer.to_string(context.person.id)
        CodeAdapter.open_in_editor(
          Application.fetch_env!(:cometoid, :data_path) <> "person_"<> id <> ".md",
          id,
          "Person",
          context.person.name)
      _ ->
        id = Integer.to_string(context.id)
        CodeAdapter.open_in_editor(
          Application.fetch_env!(:cometoid, :data_path) <> "context_"<> id <> ".md",
          id,
          "Context",
          context.title)
    end
  end

  def delete_context context do
    case context.context_type do
      "Person" ->
        id = Integer.to_string(context.person.id)
        path = Application.fetch_env!(:cometoid, :data_path) <> "person_"<> id <> ".md"
        CodeAdapter.delete path
      _ ->
        id = Integer.to_string(context.id)
        path = Application.fetch_env!(:cometoid, :data_path) <> "context_"<> id <> ".md"
        CodeAdapter.delete path
    end
  end

  def open_issue issue  do
    id = Integer.to_string(issue.id)
    path = Application.fetch_env!(:cometoid, :data_path) <> "issue_"<> id <> ".md"
    CodeAdapter.open_in_editor(path, id, "Issue", issue.title)
    CodeAdapter.read_from_editor(path)
  end

  def delete_issue issue do
    id = Integer.to_string(issue.id)
    path = Application.fetch_env!(:cometoid, :data_path) <> "issue_"<> id <> ".md"
    CodeAdapter.delete path
  end
end
