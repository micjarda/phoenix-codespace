defmodule YlapiWeb.Token do
  @salt "login socket salt" # nastav si vlastní!

  def sign(user_id) do
    Phoenix.Token.sign(YlapiWeb.Endpoint, @salt, user_id)
  end

  def verify(token) do
    Phoenix.Token.verify(YlapiWeb.Endpoint, @salt, token, max_age: 86400)
  end
end
