export const LoginSync = {
  mounted() {
    console.log("🔁 LoginSync mounted");

    // Posloucháme broadcasty z jiných tabů
    window.addEventListener("storage", (event) => {
      if (event.key === "logged_in") {
        if (event.newValue) {
          console.log("🔄 another tab logged in, redirecting...");
          window.location.href = "/dashboard";
        } else {
          console.log("🔄 another tab logged out, redirecting...");
          window.location.href = "/";
        }
      }
    });

    // Načtení aktuálního stavu – fallback
    if (window.location.pathname === "/dashboard" && !localStorage.getItem("logged_in")) {
      const stamp = `${Date.now()}-${Math.random()}`;
      console.log("📝 writing login to localStorage from dashboard", stamp);
      localStorage.setItem("logged_in", stamp);
    }
  },

  // ✨ Tohle chytne `phx:logged_in` z Elixiru
  handleEvent(event, payload) {
    if (event === "phx:logged_in") {
      const stamp = `${Date.now()}-${Math.random()}`;
      console.log("📡 handleEvent: phx:logged_in", stamp);
      localStorage.setItem("logged_in", stamp);
    }

    if (event === "phx:logged_out") {
      console.log("📡 handleEvent: phx:logged_out");
      localStorage.removeItem("logged_in");
    }
  }
};
