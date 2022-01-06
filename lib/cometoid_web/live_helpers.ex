defmodule CometoidWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  def live_modal component, opts do
    modal_opts = [id: :modal, component: component, opts: opts]
    live_component CometoidWeb.ModalComponent, modal_opts
  end
end
