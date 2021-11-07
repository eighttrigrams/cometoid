defmodule CometoidWeb.IssueLive.DeleteFlash do
  defmacro __using__([]) do
    quote do
      import CometoidWeb.IssueLive.DeleteFlash
      import Kernel, except: [def: 2]
    end
  end

  defmacro def(name_and_args, do: code) do
    quote do
      def unquote(name_and_args) do
        unquote(code)
        |> Map.delete(:flash)
      end
    end
  end
end
