// Pokud chceš použít Phoenix kanály, odkomentuj řádek níže
// import "./user_socket.js"

// Přidává phoenix_html pro podporu metod PUT/DELETE ve formulářích
import "phoenix_html"

// Připojení k Phoenix LiveView
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

// ✅ Přidáváme hook pro kopírování do clipboardu
let Hooks = {};

Hooks.Clipboard = {
  mounted() {
    console.log("📋 Clipboard Hook Mounted!"); // ✅ Debug výpis
    this.el.addEventListener("click", (event) => {
      let text = this.el.getAttribute("phx-value-token"); // ✅ Opravený atribut
      console.log("🖱️ Copy Button Clicked!", text); // ✅ Debug výpis

      if (!text || text.trim() === "") {
        console.error("⚠️ Kopírování selhalo: Žádný token nenalezen!");
        return;
      }

      navigator.clipboard.writeText(text).then(() => {
        console.log("✅ Token zkopírován:", text);
        this.el.classList.add("copied");
        setTimeout(() => this.el.classList.remove("copied"), 2000);
      }).catch(err => console.error("❌ Kopírování selhalo:", err));
    });
  }
};

// Načtení CSRF tokenu
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// Nastavení LiveView
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks  // ✅ Přidání Clipboard hooku
})

// Zobrazení progress baru při načítání stránky
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Připojení k LiveView, pokud je stránka aktivní
liveSocket.connect()

// Umožnění debugování v konzoli
window.liveSocket = liveSocket
