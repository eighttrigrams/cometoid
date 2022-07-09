defmodule CometoidWeb.IssueLive.Machine do
  defmacro __using__([]) do
    quote do
      import CometoidWeb.IssueLive.Machine
      import Kernel, except: [def: 2]
    end
  end

  defmacro def({_, _, [{_,_,[state|_]}|_]} = name_and_args, do: code) do
    create name_and_args, state, code
  end

  defmacro def({_, _, [state|_]} = name_and_args, do: code) do
    create name_and_args, state, code
  end

  defp create(name_and_args, state, code) do
    quote do
      def unquote(name_and_args) do
        state = unquote(state)
        result = unquote(code)

        case result do
          {:refresh_issues, new_state} ->
            state
            |> Map.merge(new_state)
            |> refresh_issues
          new_state ->
            state
            |> Map.merge(new_state)
        end
      end
    end
  end
end
