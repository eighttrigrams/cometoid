defmodule Cometoid.Utils do

  def separate as, p do
    {
      Enum.filter(as, p),
      Enum.reject(as, p)
    }
  end
end
