defmodule CometoidWeb.IssueLive.Person.Modals.FormComponent do
  use CometoidWeb, :live_component

  alias Cometoid.Repo.Tracker
  alias Cometoid.Repo.People
  import CometoidWeb.DateHelpers
  import CometoidWeb.DateFormHelpers

  @impl true
  def update %{ person: person } = assigns, socket do

    changeset = People.change_person person
    [birthday, use_birthday] = (if Ecto.assoc_loaded?(person.birthday) do
      [person.birthday, person.use_birthday] else [nil, false]
    end)
    {person_params, day_options} = init_params birthday, use_birthday

    person_params = Map.put person_params, "original_birthday", (if person.original_birthday do
      to_date_map(person.original_birthday)
    else
      local_time()
    end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:person_params, person_params)
     |> assign(:year_options, 1900..2050)
     |> assign(:day_options, day_options)
     |> assign(:day_options_original_birthday, 1..31)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event "changes", %{
      "_target" => ["person", "birthday", "date", _field],
      "person" => person_params }, socket do

    {day, day_options} = adjust_date person_params["birthday"]["date"]
    person_params = put_in person_params["birthday"]["date"]["day"], day

    socket
    |> assign(:day_options, day_options)
    |> assign(:person_params, person_params)
    |> return_noreply
  end

  def handle_event "changes", %{
    "_target" => ["person", "original_birthday", _field],
    "person" => person_params }, socket do

  {day, day_options} = adjust_date person_params["original_birthday"]
  person_params = put_in person_params["original_birthday"]["day"], day

  socket
  |> assign(:day_options, day_options)
  |> assign(:person_params, person_params)
  |> return_noreply
end

  def handle_event "changes", %{ "person" => person_params }, socket do

    person_params = put_back_event person_params, socket.assigns.person_params, "birthday"

    socket
    |> assign(:person_params, person_params)
    |> return_noreply
  end

  def handle_event "save", title, socket do

    person_params = socket.assigns.person_params
      |> clean_birthday
      |> Map.put("title", String.trim(title))

    save_person socket, socket.assigns.action, socket.assigns.person_params
  end

  defp save_person socket, :edit_context, context_params do
    case People.update_person(socket.assigns.person, context_params) do
      {:ok, person} ->
        send self(), {:after_edit_form_save, %{ context_id: person.context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_person socket, :new_context, person_params do
    case People.create_person(person_params) do
      {:ok, person} ->
        send self(), {:after_edit_form_save, %{ context_id: person.context.id }}
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def init_params _event = nil, false do
    params = %{
      "use_birthday" => "false",
      "birthday" => %{
        "date" => local_time()
      }
    }
    day_options = get_day_options params["birthday"]["date"]
    {params, day_options}
  end

  def init_params event, use_birthday do
    params = %{
      "use_birthday" => to_string(use_birthday),
      "birthday" => %{
        "date" => to_date_map(event.date)
      }
    }
    day_options = get_day_options params["birthday"]["date"]
    {params, day_options}
  end

  defp clean_birthday params do
    if use_birthday? params do
      params
    else
      Map.delete params, "birthday"
    end
  end

  defp use_birthday? %{ "use_birthday" => use_birthday } do
    use_birthday == "true"
  end
end
