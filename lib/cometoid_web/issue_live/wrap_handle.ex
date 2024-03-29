defmodule CometoidWeb.IssueLive.WrapHandle do
  defmacro __using__([]) do
    quote do
      use CometoidWeb, :live_view
      
      import CometoidWeb.IssueLive.WrapHandle
      import Kernel, except: [def: 2]

      defp assign_state socket, state do
        assign(socket, :state, state)
      end
      defp assign_state(socket, keys, value) when (is_list keys) do
        state = socket.assigns.state
        state = put_in state, keys, value
        assign(socket, :state, state)
      end
      defp assign_state socket, key, value do
        state = socket.assigns.state
        state = put_in state[key], value
        assign(socket, :state, state)
      end
      defp handle socket, name do
        socket
        |> assign(:handler, name)
        |> return_noreply
      end
    end
  end

  defmacro def({:handle_params, _, _} = name_and_args, do: code) do
    quote do
      def unquote name_and_args do
        socket = unquote code
        socket
        |> return_noreply
      end
    end
  end

  defmacro def({:handle_info, _, [r, socket| _]} = name_and_args, do: code) do
    [name|_] = Tuple.to_list r
    quote do
      def unquote name_and_args do
        socket = unquote socket
        modal = socket.assigns.modal
        {:noreply, socket } = result = handle (unquote code), (unquote name)
        case socket.assigns.modal do
          :keep -> {:noreply, socket |> assign(:modal, modal)}
          modal -> {:noreply, socket |> assign(:modal, nil)}
          _ -> socket
        end
      end
    end
  end

  defmacro def({:handle_event, _, [name|_]} = name_and_args, do: code) do
    quote do
      def unquote name_and_args do
        handle (unquote code), (unquote name)
      end
    end
  end

  defmacro def(name_and_args, do: code) do
    quote do
      def unquote name_and_args do
        unquote code
      end
    end
  end
end
