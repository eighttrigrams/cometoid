defmodule CometoidWeb.IssueLive.Person.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People

  @impl true
  def update(%{person: person} = assigns, socket) do

    changeset = People.change_person(person)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"context" => context_params}, socket) do
    changeset =
      socket.assigns.context
      |> Tracker.change_context(context_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{ "person" => person_params }, socket) do
    save_person(socket, socket.assigns.action, person_params)
  end

  defp save_person(socket, :edit_context, context_params) do
    case People.update_person(socket.assigns.person, context_params) do
      {:ok, person} ->
        send self(), {:after_edit_form_save, %{ context_id: person.context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_person(socket, :new_context, person_params) do
    case People.create_person(person_params) do
      {:ok, person} ->
        send self(), {:after_edit_form_save, %{ context_id: person.context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
