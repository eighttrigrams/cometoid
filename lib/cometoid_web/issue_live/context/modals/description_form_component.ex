defmodule CometoidWeb.IssueLive.Context.Modals.DescriptionFormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People

  @impl true
  def update(%{context: context} = assigns, socket) do

    changeset = unless Map.has_key?(context, :view) do
      People.change_person_description(context)
    else
      Tracker.change_context(context)
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  def handle_event("save", %{"description" => description }, socket) do
    save_context(socket, socket.assigns.action, %{ description: description })
  end

  defp save_context(socket, :describe_context, context_params = %{ description: _description }) do

    f = if is_in_people_view? socket do
      &People.update_person_description/2
    else
      &Tracker.update_context/2
    end

    case f.(socket.assigns.context, context_params) do
      {:ok, context} ->
        send self(), {:after_edit_form_save, %{ context_id: context.id }}
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp is_in_people_view? socket do
    not Map.has_key? socket.assigns.context, :view
  end
end
