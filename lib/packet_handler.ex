defmodule NetLogger.PacketHandler do
  alias NetLogger.Packet
  import NetLogger.PacketHandler.NameProvider, only: [via: 1]
  use GenServer

  def start_link(identifier) when is_binary(identifier) do
    GenServer.start_link(__MODULE__, [identifier], name: via(identifier))
  end

  def handle_packet(identifier, packet) do
    case GenServer.whereis(via(identifier)) do
      pid when is_pid(pid) ->
        GenServer.call(pid, {:handle_packet, packet})
      nil ->
        {:ok, pid} = NetLogger.PacketHandler.Supervisor.add_child(identifier)
        GenServer.call(pid, {:handle_packet, packet})
    end
  end

  def init([identifier]) do
    database = if File.exists?("#{identifier}.sqlite3") do
      {:ok, database} = Sqlite.open(database: "#{identifier}.sqlite3")
      database
    else
      {:ok, database} = Sqlite.open(database: "#{identifier}.sqlite3")
      {:ok, statement} = Sqlite.prepare(database, "CREATE TABLE logs (id TEXT, time int, message string, level string, verbosity string)")
      {:ok, _} = Sqlite.execute(database, statement, [])
      database
    end
    {:ok, %{identifier: identifier, database: database}}
  end

  def terminate(_, state) do
    Sqlite.close(state.database)
  end

  def handle_call({:handle_packet, %Packet{type: :ping, id: id, data: data}}, _from, state) do
    {:reply, Packet.new(id, :pong, data), state}
  end

  def handle_call({:handle_packet, %Packet{type: :log, id: id, data: json}}, _from, state) do
    log = Jason.decode!(json)
    {:ok, statement} = Sqlite.prepare(state.database, "INSERT INTO logs (id, time, message, level, verbosity) VALUES ($1, $2, $3, $4, $5)")
    {:ok, _} = Sqlite.execute(state.database, statement, [id, log["time"], log["message"], log["level"], log["verbosity"]])
    IO.puts ["#{state.identifier} ", to_string(log["time"])," => ", log["message"]]
    {:reply, Packet.new(id, :ok, <<>>), state}
  end

  def handle_call({:handle_packet, packet}, _, state) do
    IO.puts "can't handle packet: #{inspect packet}"
    {:reply, nil, state}
  end
end
