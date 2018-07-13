defmodule NetLogger.UDP do
  defmacro __using__(_) do
    quote do
      @port 48042
      @bcast {255, 255, 255, 255}
    end
  end
end
