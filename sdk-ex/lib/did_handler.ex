defmodule DidHandler do
  alias DidHandler.Did.Document
  @moduledoc """
    Module to handle DID & VC.\n
    Follow the spec:\n
    > https://www.w3.org/TR/did-core/
  """

  # +-----------------+
  # | READ OPERATIONS |
  # +-----------------+

  @doc """
    see in https://www.w3.org/TR/did-core/#did-syntax
  """
  @spec get_syntax(map()) :: String.t()
  def get_syntax(%{key_addr: addr}) do
    "did:ed25519:0x#{addr}"
  end

  # TODO
  def handle_url_syntax(did_syntax_str) do
  end



  @doc """
    see in https://www.w3.org/TR/did-core/#a-simple-example
    Example:
    ```
      %DidHandler.Did.Document{
        authentication: [
          %{
            addr: "0x73c7448760517E3E6e416b2c130E3c6dB2026A1d",
            chain_name: "ethereum",
            description: "theAcctToDevelopSth",
            is_verified: true,
            type: :Secp256k1
          }
        ],
        context: ["https://www.w3.org/ns/did/v1"],
        id: "did:ed25519:0x0x1168e88ffc5cec53b398b42d61885bbb"
      }
    ```
  """
  def get_document(resource) do
    did = get_syntax(resource)
    %Document{
      id: did,
      authentication: build_auth(resource)
    }
  end

  def build_auth(%{addr_infos: addr_infos}) do
    Enum.map(addr_infos, &(handle_addr_info(&1)))
  end

  @doc """
    see in https://www.w3.org/TR/did-core/#authentication
  """
  def handle_addr_info(%{addr: addr, signature: signature} = addr_info) do
    addr_type = ed25519_or_sepc256k1(addr)
    is_verified = is_nil(signature)
    addr_info
    |> Map.put(:type, addr_type)
    |> Map.put(:is_verified, is_verified)
    |> reject_nils()
    |> Enum.into(%{})
  end

  def ed25519_or_sepc256k1(addr) do
    case byte_size(addr) do
      34 ->
        :Ed25519
      42 ->
        :Secp256k1
    end
  end

  def reject_nils(payload) do
    Enum.reject(payload, fn {_key, value} ->
      is_nil(value)
    end)
  end

  # +-------------------------+
  # | WRITE OPERATIONS // TODO|
  # +-------------------------+

  def add_addr(priv_key, addr, description, msg, signature) do

  end

  def add_addr(priv_key, addr, description) do

  end



end
