defmodule DidHandler.Constants do
  @default_endpoint "http://localhost:9851"
  @default_contract_addrs %{
    addr_aggr: "0x1168e88ffc5cec53b398b42d61885bbb"
  }

  def get_starcoin_endpoint() do
    endpoint = Application.fetch_env(:did_handler, :starcoin_endpoint)
    if endpoint == :error do
      @default_endpoint
    else
      endpoint
    end

  end

  def get_contract(name) do
    contracts =
      Application.fetch_env(:did_handler, :contract_addrs)
    if contracts == :error do
      Map.fetch!(@default_contract_addrs, name)
    else
        Map.fetch!(contracts, name)
    end
  end
end
