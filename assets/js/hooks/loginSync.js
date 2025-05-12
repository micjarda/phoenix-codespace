import { Socket } from "phoenix"

export const LoginSync = {
  mounted() {
    console.log("🔁 LoginSync mounted")

    const token = document.querySelector("meta[name='user-token']")?.content
    if (!token) {
      console.warn("🚫 No user token found for login sync.")
      return
    }

    const socket = new Socket("/login_socket", { params: { token } })
    socket.connect()

    this.channel = socket.channel("login:sync", {})
    this.channel
      .join()
      .receive("ok", () => {
        console.log("✅ Joined login:sync channel")
        this.channel.push("login_event", { stamp: Date.now() })
      })
      .receive("error", (err) => {
        console.error("❌ Failed to join login:sync", err)
      })
  }
}
