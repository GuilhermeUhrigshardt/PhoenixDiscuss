defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  plug Ueberauth

  alias Discuss.Users

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
    signin(conn, user_params)
  end

  defp signin(conn, user_params) do
    case Users.upsert_user(user_params) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: Routes.topic_path(conn, :index))
    end
  end
end
