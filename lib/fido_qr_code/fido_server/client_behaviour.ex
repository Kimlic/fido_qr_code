defmodule FidoQrCode.FidoServer.ClientBehaviour do
  @callback create_reg_request(binary) :: {:ok, map} | {:error, map}
  @callback create_auth_request :: {:ok, map} | {:error, map}
  @callback check_username_registered(binary) :: {:ok, map} | {:error, map}
end
