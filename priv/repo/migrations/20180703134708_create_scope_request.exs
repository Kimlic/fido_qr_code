defmodule FidoQrCode.Repo.Migrations.CreateScopeRequest do
  use Ecto.Migration

  def change do
    create table(:scope_requests, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:status, :string, null: false)
      add(:scopes, :string, null: false)
      add(:used, :boolean, default: false)
      add(:username, :string)

      timestamps(type: :utc_datetime)
    end
  end
end
