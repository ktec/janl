defmodule NetLogger.Log do
  @derive Jason.Encoder
  defstruct [
    time: nil,
    level: nil,
    verbosity: nil,
    message: nil,
  ]
end
