defmodule FidoQrCodeTest do
  use ExUnit.Case
  import Mox
  alias FidoQrCode.ScopeRequest
  doctest FidoQrCode

  describe "generate qr code and process it" do
    test "happy path" do
      expect(FidoServerClientMock, :check_username_registered, fn username ->
        assert is_binary(username)
        {:ok, %HTTPoison.Response{status_code: 404}}
      end)

      expect(FidoServerClientMock, :create_reg_request, fn username ->
        assert is_binary(username)
        {:ok, %{"challenge" => "some-random-challenge"}}
      end)

      # 1. Create ScopeRequest with predefined scopes
      assert {:ok, scope_request = %ScopeRequest{}} = FidoQrCode.create_scope_request()

      # 2. Generate QR Code from ScopeRequest
      # Mobile Application scan code and get one time url with ScopeRequest id.
      # By requesting url ScopeRequest will be processed
      assert FidoQrCode.generate_qr_code(scope_request)

      # 3. Process ScopeRequest after scanned code
      # Result of processing it's response with two fields
      #   scope_request - ScopeRequest
      #   fido - Fido UAF regRequest or authRequest
      assert {:ok, resp} = FidoQrCode.process_scope_request(scope_request, "test-username")

      assert Map.has_key?(resp, :fido)
      assert Map.has_key?(resp, :scope_request)
      assert %ScopeRequest{username: "test-username"} = resp.scope_request

      # ScopeRequest already processed
      assert {:error, :scope_request_already_processed} =
               FidoQrCode.process_scope_request(scope_request.id, "test")
    end

    test "call auth request for registered username" do
      expect(FidoServerClientMock, :check_username_registered, fn username ->
        assert is_binary(username)
        {:ok, %HTTPoison.Response{status_code: 204}}
      end)

      expect(FidoServerClientMock, :create_auth_request, fn ->
        {:ok, %{"challenge" => "some-random-challenge"}}
      end)

      assert {:ok, scope_request = %ScopeRequest{}} = FidoQrCode.create_scope_request()
      assert FidoQrCode.generate_qr_code(scope_request)
      assert {:ok, resp} = FidoQrCode.process_scope_request(scope_request, "test-username")
      assert Map.has_key?(resp, :fido)
      assert Map.has_key?(resp, :scope_request)
    end

    test "scope request expired" do
      assert {:ok, scope_request = %ScopeRequest{}} = FidoQrCode.create_scope_request()

      inserted_at =
        :fido_qr_code
        |> Confex.fetch_env!(:scope_request_ttl)
        |> Kernel.+(:os.system_time(:second) + 2)
        |> DateTime.from_unix!()

      # put expired inserted_at
      scope_request = Map.put(scope_request, :inserted_at, inserted_at)

      assert FidoQrCode.generate_qr_code(scope_request)

      assert {:error, :scope_request_expired} =
               FidoQrCode.process_scope_request(scope_request, "test-username")
    end
  end
end
