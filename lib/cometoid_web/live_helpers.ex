defmodule CometoidWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_modal component, opts do
    modal_opts = [id: :modal, component: component, opts: opts]
    live_component CometoidWeb.ModalComponent, modal_opts
  end

  def return_noreply(socket), do: {:noreply, socket |> Map.delete(:flash) } # TODO review flash

  def return_ok(socket), do: {:ok, socket}

  def to_int s do
    {int, ""} = Integer.parse s
    int
  end
end
