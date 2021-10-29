defmodule Cometoid.Model.Tracker.Relation do
  use Ecto.Schema

  alias Cometoid.Model.Tracker

  schema "context_issue" do
    belongs_to :context, Tracker.Context
    belongs_to :issue, Tracker.Issue
  end
end
