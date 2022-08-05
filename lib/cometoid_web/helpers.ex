defmodule CometoidWeb.Helpers do

  def markdownify nil do
    ""
  end
  def markdownify raw do
    case Earmark.as_html raw do
      {:ok, html, _} -> html
      _ -> raw
    end
  end

  def demarkdownify md do
    with [_, nil] <- ["***", (Regex.run ~r/(\*\*\*.+?\*\*\*)/, md)],
         [_, nil] <- ["**", (Regex.run ~r/(\*\*.+?\*\*)/, md)],
         [_, nil] <- ["*", (Regex.run ~r/(\*.+?\*)/, md)],
         [_, nil] <- ["`", (Regex.run ~r/(`.+?`)/, md)] do
      md
    else
      [char, [_, inner | _]] ->
        md = String.replace md, inner, (String.replace inner, char, ""), global: false
        demarkdownify md
    end
  end
end
