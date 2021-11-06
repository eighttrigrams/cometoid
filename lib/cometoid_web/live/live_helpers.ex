defmodule CometoidWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_modal(socket, component, opts) do
    modal_opts = [id: :modal, component: component, opts: opts]
    live_component(socket, CometoidWeb.ModalComponent, modal_opts)
  end
end
