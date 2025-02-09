defmodule YlapiWeb.AppHTML do
  use YlapiWeb, :html

  # Připojí šablony z adresáře app_html/
  embed_templates "app_html/*"
end
