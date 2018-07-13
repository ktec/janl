defmodule NetLogger.Crypto do
  def public_key_pem do
    File.read!("public.pem")
  end

  def public do
    [public] = :public_key.pem_decode(File.read!("public.pem"))
    :public_key.pem_entry_decode(public)
  end

  def private do
    [private] = :public_key.pem_decode(File.read!("private.pem"))
    :public_key.pem_entry_decode(private)
  end

  def encrypt(message, public) when is_binary(message) do
    :public_key.encrypt_public(message, public)
    |> Base.encode64()
  end

  def decrypt(encrypted, private) when is_binary(encrypted) do
    Base.decode64!(encrypted)
    |> :public_key.decrypt_private(private)
  end
end
