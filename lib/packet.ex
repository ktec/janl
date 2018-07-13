defmodule NetLogger.Packet do
  alias NetLogger.Packet
  @derive Jason.Encoder
  defstruct [
    :id, :type, :data
  ]

  def new(id, type, data) when is_binary(data) do
    %Packet{id: id, type: type, data: data}
  end

  def encode(%Packet{} = packet) do
    Jason.encode!(packet)
    |> Base.encode64()
  end

  def decode(binary) when is_binary(binary) do
    case Base.decode64!(binary) |> Jason.decode!() do
      %{"id" => id, "type" => type, "data" => data} ->
        new(id, String.to_atom(type), data)
      _ -> raise("not a Net Logger packet")
    end
  end
end
