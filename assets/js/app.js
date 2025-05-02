import "phoenix_html"
import topbar from "../vendor/topbar"
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"

let Hooks = {}

// 🔊 Broadcast Channel init
const bc = new BroadcastChannel("yl-sync")

// 🟥 Logout Hook
Hooks.LogoutSync = {
  mounted() {
    console.log("🔴 Logout hook triggered")
    bc.postMessage("logout")
  }
}

// 🟦 LoginSync Hook
Hooks.LoginSync = {
  mounted() {
    const alreadySent = sessionStorage.getItem("yl-login-sent")
    const isLoggedIn = document.body.dataset.loggedIn === "true"

    if (isLoggedIn && !alreadySent) {
      bc.postMessage("login")
      sessionStorage.setItem("yl-login-sent", "true")
      console.log("📥 LoginSync triggered")
    }
  }
}

// 🌐 Sync messages between tabs
bc.onmessage = (event) => {
  const msg = event.data
  const path = window.location.pathname
  const isLoggedIn = document.body.dataset.loggedIn === "true"

  const isLoginPage = path === "/" || path === "/users/log_in"
  const isDashboard = path.startsWith("/dashboard")
  const redirected = sessionStorage.getItem("yl-login-redirected")

  if (msg === "logout") {
    console.log("📤 Logout received")
    sessionStorage.removeItem("yl-login-sent")
    sessionStorage.removeItem("yl-login-redirected")
    window.location.href = "/"
  }

  if (msg === "login") {
    console.log("📥 Login received")

    if (isLoginPage && isLoggedIn && !redirected) {
      console.log("➡️ Redirecting to dashboard")
      sessionStorage.setItem("yl-login-redirected", "true")
      window.location.href = "/dashboard"
    }

    if (isDashboard && isLoggedIn) {
      sessionStorage.removeItem("yl-login-redirected")
    }
  }
}

// 🔐 CSRF token
let csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// ⏳ Topbar
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", () => topbar.show(300))
window.addEventListener("phx:page-loading-stop", () => topbar.hide())

liveSocket.connect()
window.liveSocket = liveSocket
