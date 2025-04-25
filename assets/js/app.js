import "../css/app.css"
import "phoenix_html"
import topbar from "../vendor/topbar"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let Hooks = {}

// LogoutSync Hook
Hooks.LogoutSync = {
  mounted() {
    console.log("🔴 Logout hook triggered")
    localStorage.setItem("yl-logout", Date.now())
  }
}

// LoginSync Hook
Hooks.LoginSync = {
  mounted() {
    window.addEventListener("phx:login-sync", () => {
      localStorage.setItem("yl-login", Date.now().toString())
      console.log("📥 LoginSync triggered")
    })
  }
}

// Global tab sync (listen for changes)
window.addEventListener("storage", (event) => {
  if (event.key === "yl-logout") {
    console.log("📤 Logout detected in another tab")
    window.location.href = "/"
  }

  if (event.key === "yl-login") {
    console.log("📥 Login detected in another tab")

    const isLoginPage = ["/", "/users/log_in"].includes(window.location.pathname)

    if (isLoginPage) {
      window.location.reload()
    }
  }
})

// CSRF token
let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks
})

// Topbar
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket
