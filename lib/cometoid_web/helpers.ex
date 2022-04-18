defmodule CometoidWeb.Helpers do

  def convert raw do # TODO put this somewhere else
    case Earmark.as_html raw do
      {:ok, html, _} -> html
      _ -> raw
    end
  end

  def demarkdownify md do
    with ["**", nil] <- ["**", (Regex.run ~r/(\*\*.+?\*\*)/, md)],
         ["*", nil] <- ["*", (Regex.run ~r/(\*.+?\*)/, md)],
         ["`", nil] <- ["`", (Regex.run ~r/(`.+?`)/, md)] do
      md
    else
      [char, [_, inner | _]] = m ->
        md = String.replace md, inner, (String.replace inner, char, ""), global: false
        demarkdownify md
    end
  end
end
