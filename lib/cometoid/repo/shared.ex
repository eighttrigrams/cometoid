defmodule Cometoid.Repo.Shared do

  alias Cometoid.Repo

  def do_context_preload context do
    context
    |> Repo.preload(person: :birthday)
    |> Repo.preload(:text)
    |> Repo.preload(issues: :issue)
    |> Repo.preload(:secondary_contexts)
  end

  def do_issues_preload issue do
    issue
    |> Repo.preload(contexts: :context)
    |> Repo.preload(:event)
    |> Repo.preload(:issues)
  end
end