import "phoenix_html"
import topbar from "../vendor/topbar"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { LoginSync } from "./hooks/loginSync.js"

let Hooks = {}
Hooks.LoginSync = LoginSync

let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket
