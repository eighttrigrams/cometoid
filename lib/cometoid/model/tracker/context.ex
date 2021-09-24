defmodule Cometoid.Model.Tracker.Context do
  use Ecto.Schema
  import Ecto.Changeset

  alias Cometoid.Model.Tracker
  alias Cometoid.Model.People
  alias Cometoid.Model.Writing

  schema "contexts" do
    field :title, :string
    field :context_type, :string
    field :important, :boolean, default: false

    many_to_many(
      :issues,
      Tracker.Issue,
      join_through: "context_issue",
      on_replace: :delete,
      on_delete: :delete_all
    )

    # 0 or 1 association
    has_one :person, People.Person, on_delete: :delete_all
    # 0 or 1 association
    has_one :text, Writing.Text, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset context, attrs do
    context
    |> cast(attrs, [:title, :context_type, :important])
    |> put_assoc_person(attrs)
    |> put_assoc_text(attrs)
    |> validate_required([:title, :context_type])
  end

  defp put_assoc_person(context, %{ "person" => person }), do: put_assoc(context, :person, person)
  defp put_assoc_person(context, _), do: context

  defp put_assoc_text(context, %{ "text" => text }), do: put_assoc(context, :text, text)
  defp put_assoc_text(context, _), do: context
end
