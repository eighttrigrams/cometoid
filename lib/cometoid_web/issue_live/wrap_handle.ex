defmodule CometoidWeb.IssueLive.WrapHandle do
  defmacro __using__([]) do
    quote do
      import CometoidWeb.IssueLive.WrapHandle
      import Kernel, except: [def: 2]
    end
  end

  defmacro def({:handle_params, _, _} = name_and_args, do: code) do
    quote do
      def unquote(name_and_args) do
        socket = unquote(code)
        socket
        |> assign(:action, :handle_params)
        |> return_noreply
      end
    end
  end

  defmacro def({:handle_info, _, [r|_]} = name_and_args, do: code) do
    [name|_] = Tuple.to_list r
    quote do
      def unquote(name_and_args) do
        socket = unquote(code)
        socket
        |> assign(:action, unquote(name))
        |> return_noreply
      end
    end
  end

  defmacro def({:handle_event, _, [name|_]} = name_and_args, do: code) do
    quote do
      def unquote(name_and_args) do
        socket = unquote(code)
        socket
        |> assign(:action, unquote(name))
        |> return_noreply
      end
    end
  end

  defmacro def(name_and_args, do: code) do
    quote do
      def unquote(name_and_args) do
        unquote(code)
      end
    end
  end
end
