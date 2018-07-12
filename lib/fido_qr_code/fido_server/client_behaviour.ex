defmodule FidoQrCode.FidoServer.ClientBehaviour do
  @callback create_request(binary) :: {:ok, map} | {:error, map}
  @callback create_reg_request(binary) :: {:ok, map} | {:error, map}
  @callback create_auth_request :: {:ok, map} | {:error, map}
end
