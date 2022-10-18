defmodule DidHandler.ContractInteractor.AddrAggregator do
  @moduledoc """
    See MOVE Contract in: \n
    > https://github.com/WeLightProject/Web3-dApp-Camp/tree/main/move-dapp/my-library \n
    Short Description: It's a contract about Library and Books to show how the resources working in MOVE Lang.
  """
  alias Web3MoveEx.Starcoin.Caller
  alias Web3MoveEx.Starcoin.Caller.Contract
  alias DidHandler.Constants

  def get_resource(addr, :addr_aggr) do
    Constants.get_starcoin_endpoint()
    |> Contract.get_resource(
      addr,
      struct()
    )
    |> handle_res()
  end

  def struct() do
    contract_addr()
    |> Caller.build_namespace("AddrAggregatorV4","AddrAggregator")
  end

  def contract_addr() do
    Constants.get_contract(:addr_aggr)
  end

  def handle_res({:error, payload}), do: {:error, inspect(payload)}
  def handle_res({:ok, %{result: result}}) do
    do_handle_res(result)

  end

  def do_handle_res(nil), do: {:ok, nil}
  def do_handle_res(result) do
    %{value: [["key_addr",  %{Address: key_addr}],["addr_infos", %{Vector: vec_list}]]} = result
    {
      :ok,
      %{key_addr: key_addr,
      addr_infos: Enum.map(vec_list, &(hanle_k_v(&1)))
    }
    }
  end

  def hanle_k_v(%{Struct: %{value: values}}) do
    values
    |> Enum.map(&(List.to_tuple(&1)))
    |> Enum.map(fn {key, value} ->
      {key, Web3MoveEx.TypeTranslator.parse_type_in_move(value)}
    end)
    |> Enum.map(fn {key, value} ->
      if key in ["msg", "signature"] && value == "" do
        {key, nil}
      else
        {key, value}
      end
    end)
    |> Enum.into(%{})
    |> ExStructTranslator.to_atom_struct()

  end

end
