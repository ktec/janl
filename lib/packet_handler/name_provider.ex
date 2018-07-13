defmodule NetLogger.PacketHandler.NameProvider do
  use GenServer

  def via(identifier) do
    {:via, __MODULE__, identifier}
  end

  def whereis_name(identifier) do
    GenServer.call(__MODULE__, {:whereis_name, identifier})
  end

  def register_name(identifier, pid) do
    GenServer.call(__MODULE__, {:register_name, identifier, pid})
  end

  def unregister_name(identifier) do
    GenServer.call(__MODULE__, {:unregister_name, identifier})
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, [name: __MODULE__])
  end

  def init([]) do
    {:ok, %{}}
  end

  def handle_call({:whereis_name, id}, _, state) do
    {:reply, Map.get(state, id) || :undefined, state}
  end

  def handle_call({:register_name, id, pid}, _, state) do
    {:reply, :yes, Map.put(state, id, pid)}
  end

  def handle_call({:unregister_name, id}, _, state) do
    if Map.get(state, id) do
      {:reply, :yes, Map.delete(state, id)}
    else
      {:reply, :no, state}
    end
  end
end
