defmodule NetLogger.Server do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    children = [
      {NetLogger.PacketHandler.Supervisor, []},
      {NetLogger.UDP.Server, []}
    ]
    Supervisor.init(children, [strategy: :one_for_all])
  end
end
