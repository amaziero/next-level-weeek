defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase

  alias Rocketpay.{ Account, User }

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "alison",
        password: "123123",
        email: "alison@gmail.com",
        nickname: "amaziero",
        age: 25
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user((params))

      conn = put_req_header(conn, "authorization", "Basic dGFudG9mYXo6MTIzMTIz")

      {:ok, conn: conn, account_id: account_id}
    end

    test "When all params are valid, make an deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response =
      conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:ok)

      assert %{"account" => %{
          "balance" => "50.00",
          "id" => _id
        },
        "message" => "Balance changed successfully"
      } = response
    end

    test "When there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response =
      conn
      |> post(Routes.accounts_path(conn, :deposit, account_id, params))
      |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert expected_response = response
    end
  end
end
