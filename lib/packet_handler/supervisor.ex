defmodule NetLogger.PacketHandler.Supervisor do
  use Supervisor

  def add_child(identifier) do
    args = [identifier]
    opts = [restart: :transient, id: identifier]
    spec = worker(NetLogger.PacketHandler, args, opts)
    Supervisor.start_child(__MODULE__, spec)
  end

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([]) do
    children = [
      {NetLogger.PacketHandler.NameProvider, []}
    ]
    Supervisor.init(children, [strategy: :one_for_one])
  end
end
