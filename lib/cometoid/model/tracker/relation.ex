defmodule Cometoid.Model.Tracker.Relation do
  use Ecto.Schema

  alias Cometoid.Model.Tracker

  schema "context_issue" do
    field :issue_type, :string

    belongs_to :context, Tracker.Context
    belongs_to :issue, Tracker.Issue
  end
end
