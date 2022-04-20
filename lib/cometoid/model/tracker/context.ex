defmodule Cometoid.Model.Tracker.Context do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker
  alias Cometoid.Model.People
  alias Cometoid.Model.Writing

  def calc_open_issues context do
    length(Enum.filter(context.issues, fn issue -> issue.issue.done != true end))
  end

  def calc_issues_done context do
    length(Enum.filter(context.issues, fn issue -> issue.issue.done == true end))
  end

  schema "contexts" do
    field :title, :string
    field :short_title, :string
    field :view, :string
    field :important, :boolean, default: false
    field :description, :string
    field :is_tag?, :boolean, [source: :is_tag]
    field :search_mode, :integer, default: 0 # 0 = most recently changed, 1 = alphanumerically ascending, 2 = alphanumerically descending

    has_many(
      :issues,
      Tracker.Relation,
      on_replace: :delete,
      on_delete: :delete_all
    )

    # 0 or 1 association
    has_one :person, People.Person, on_delete: :delete_all
    # 0 or 1 association
    has_one :text, Writing.Text, on_delete: :delete_all

    many_to_many :secondary_contexts,
      Tracker.Context,
      join_through: "context_context",
      join_keys: [parent_id: :id, child_id: :id],
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset context, attrs do
    context
    |> cast(attrs, [:title, :short_title, :search_mode, :view, :important, :description, :is_tag?])
    |> put_assoc_person(attrs)
    |> put_assoc_text(attrs)
    |> validate_required([:title, :view])
  end

  def link_contexts_changeset context, attrs do
    context
    |> cast(attrs, [])
    |> put_assoc_secondary_contexts(attrs)
  end

  defp put_assoc_secondary_contexts(context, %{ "secondary_contexts" => secondary_contexts }), do: put_assoc(context, :secondary_contexts, secondary_contexts)
  defp put_assoc_secondary_contexts(context, _), do: context

  defp put_assoc_person(context, %{ "person" => person }), do: put_assoc(context, :person, person)
  defp put_assoc_person(context, _), do: context

  defp put_assoc_text(context, %{ "text" => text }), do: put_assoc(context, :text, text)
  defp put_assoc_text(context, _), do: context
end
