// app.js — frontend logic for TravelDatabase

// ── STATE ────────────────────────────────────────────────────────────────────

const state = {
  currentUser: null, // { user_id, username, user_type } or null if guest
  allCities: [], // full city list loaded on startup
  currentCityId: null,
  currentHotels: [], // hotels for the selected city (pre-filter)
  filteredHotels: [], // hotels after applying filters
  selectedHotel: null, // hotel object the user clicked "Reserve" on
};

// ── API STUBS ─────────────────────────────────────────────────────────────────
// Replace each stub with a real fetch() call to Flask backend.
// Example:  return await fetch('/api/cities').then(r => r.json());

const API = {
  getCities: () => fetch("/api/cities").then((r) => r.json()),

  getHotelsByCity: (cityId) =>
    fetch(`/api/cities/${cityId}/hotels`).then((r) => r.json()),

  login: (email, password) =>
    fetch("/api/auth/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, password }),
    }).then((r) => r.json()),

  register: (data) =>
    fetch("/api/auth/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    }).then((r) => r.json()),

  makeReservation: (data) =>
    fetch("/api/reservations", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data),
    }).then((r) => r.json()),

  me: () => fetch("/api/auth/me").then((r) => (r.ok ? r.json() : null)),

  logout: () => fetch("/api/auth/logout", { method: "POST" }),
};

// ── ELEMENT REFS ──────────────────────────────────────────────────────────────

const $ = (id) => document.getElementById(id);

const els = {
  // nav
  navAuthButtons: $("nav-auth-buttons"),
  navUserInfo: $("nav-user-info"),
  navUsername: $("nav-username"),
  btnOpenLogin: $("btn-open-login"),
  btnOpenSignup: $("btn-open-signup"),
  btnLogout: $("btn-logout"),
  // hero
  heroNoteGuest: $("hero-note-guest"),
  heroNoteUser: $("hero-note-user"),
  heroSigninLink: $("hero-signin-link"),
  // selectors
  countrySelect: $("country-select"),
  citySelect: $("city-select"),
  // filters
  filterStars: $("filter-stars"),
  filterBudget: $("filter-budget"),
  filterRestaurant: $("filter-restaurant"),
  filterAvailable: $("filter-available"),
  btnApplyFilters: $("btn-apply-filters"),
  btnClearFilters: $("btn-clear-filters"),
  // city info
  cityInfoCard: $("city-info-card"),
  cityInfoName: $("city-info-name"),
  cityInfoDesc: $("city-info-desc"),
  cityPriceBadge: $("city-price-badge"),
  // results
  resultsHeader: $("results-header"),
  resultsCount: $("results-count"),
  hotelGrid: $("hotel-grid"),
  emptyState: $("empty-state"),
  initialPrompt: $("initial-prompt"),
  // auth modal
  authModal: $("auth-modal"),
  authModalClose: $("auth-modal-close"),
  tabLogin: $("tab-login"),
  tabSignup: $("tab-signup"),
  formLogin: $("form-login"),
  formSignup: $("form-signup"),
  loginEmail: $("login-email"),
  loginPassword: $("login-password"),
  loginError: $("login-error"),
  signupUsername: $("signup-username"),
  signupEmail: $("signup-email"),
  signupPassword: $("signup-password"),
  signupBudgetMin: $("signup-budget-min"),
  signupBudgetMax: $("signup-budget-max"),
  signupError: $("signup-error"),
  // reserve modal
  reserveModal: $("reserve-modal"),
  reserveModalClose: $("reserve-modal-close"),
  reserveHotelName: $("reserve-hotel-name"),
  formReserve: $("form-reserve"),
  reserveCheckin: $("reserve-checkin"),
  reserveCheckout: $("reserve-checkout"),
  reserveGuests: $("reserve-guests"),
  reserveSummary: $("reserve-summary"),
  reserveTotal: $("reserve-total"),
  reserveError: $("reserve-error"),
  // detail modal
  detailModal: $("detail-modal"),
  detailModalClose: $("detail-modal-close"),
  detailContent: $("detail-content"),
};

// ── AUTH HELPERS ──────────────────────────────────────────────────────────────

function setUser(user) {
  state.currentUser = user;
  if (user) {
    els.navAuthButtons.classList.add("hidden");
    els.navUserInfo.classList.remove("hidden");
    els.navUsername.textContent = user.username;
    els.heroNoteGuest.classList.add("hidden");
    els.heroNoteUser.classList.remove("hidden");
    els.heroNoteUser.textContent = `Welcome back, ${user.username}! You can browse and make reservations.`;
  } else {
    els.navAuthButtons.classList.remove("hidden");
    els.navUserInfo.classList.add("hidden");
    els.heroNoteGuest.classList.remove("hidden");
    els.heroNoteUser.classList.add("hidden");
  }
  // re-render hotel cards so reserve buttons update
  if (state.filteredHotels.length) renderHotels(state.filteredHotels);
}

// ── AUTH MODAL ────────────────────────────────────────────────────────────────

function openAuthModal(tab = "login") {
  els.authModal.classList.remove("hidden");
  switchAuthTab(tab);
}
function closeAuthModal() {
  els.authModal.classList.add("hidden");
}
function switchAuthTab(tab) {
  if (tab === "login") {
    els.formLogin.classList.remove("hidden");
    els.formSignup.classList.add("hidden");
    els.tabLogin.classList.add("active");
    els.tabSignup.classList.remove("active");
  } else {
    els.formLogin.classList.add("hidden");
    els.formSignup.classList.remove("hidden");
    els.tabLogin.classList.remove("active");
    els.tabSignup.classList.add("active");
  }
}

els.btnOpenLogin.addEventListener("click", () => openAuthModal("login"));
els.btnOpenSignup.addEventListener("click", () => openAuthModal("signup"));
els.heroSigninLink.addEventListener("click", (e) => {
  e.preventDefault();
  openAuthModal("login");
});
els.authModalClose.addEventListener("click", closeAuthModal);
els.authModal.addEventListener("click", (e) => {
  if (e.target === els.authModal) closeAuthModal();
});
els.tabLogin.addEventListener("click", () => switchAuthTab("login"));
els.tabSignup.addEventListener("click", () => switchAuthTab("signup"));

els.btnLogout.addEventListener("click", async () => {
  await API.logout();
  setUser(null);
});

els.formLogin.addEventListener("submit", async (e) => {
  e.preventDefault();
  els.loginError.classList.add("hidden");
  const result = await API.login(els.loginEmail.value, els.loginPassword.value);
  if (result.error) {
    els.loginError.textContent = result.error;
    els.loginError.classList.remove("hidden");
  } else {
    setUser(result);
    closeAuthModal();
  }
});

els.formSignup.addEventListener("submit", async (e) => {
  e.preventDefault();
  els.signupError.classList.add("hidden");
  const budgetMin = parseFloat(els.signupBudgetMin.value) || 0;
  const budgetMax = parseFloat(els.signupBudgetMax.value) || 0;
  if (budgetMax && budgetMax < budgetMin) {
    els.signupError.textContent = "Budget max must be >= budget min.";
    els.signupError.classList.remove("hidden");
    return;
  }
  const result = await API.register({
    username: els.signupUsername.value,
    email: els.signupEmail.value,
    password: els.signupPassword.value,
    preferred_budget_min: budgetMin,
    preferred_budget_max: budgetMax,
  });
  if (result.error) {
    els.signupError.textContent = result.error;
    els.signupError.classList.remove("hidden");
  } else {
    setUser(result);
    closeAuthModal();
  }
});

// ── CITY / COUNTRY LOADING ────────────────────────────────────────────────────

async function loadCities() {
  state.allCities = await API.getCities();
  populateCountrySelect();
}

function populateCountrySelect() {
  // build sorted unique country list
  const countries = [...new Set(state.allCities.map((c) => c.country))].sort();
  els.countrySelect.innerHTML =
    '<option value="">— Select a country —</option>';
  countries.forEach((country) => {
    const opt = document.createElement("option");
    opt.value = country;
    opt.textContent = country;
    els.countrySelect.appendChild(opt);
  });
}

els.countrySelect.addEventListener("change", () => {
  const country = els.countrySelect.value;
  els.citySelect.innerHTML = '<option value="">— Select a city —</option>';
  els.citySelect.disabled = !country;

  if (!country) {
    resetCityView();
    return;
  }

  const cities = state.allCities
    .filter((c) => c.country === country)
    .sort((a, b) => a.city_name.localeCompare(b.city_name));
  cities.forEach((city) => {
    const opt = document.createElement("option");
    opt.value = city.city_id;
    opt.textContent = city.city_name;
    els.citySelect.appendChild(opt);
  });

  // auto-select if only one city in that country
  if (cities.length === 1) {
    els.citySelect.value = cities[0].city_id;
    els.citySelect.dispatchEvent(new Event("change"));
  }
});

els.citySelect.addEventListener("change", async () => {
  const cityId = parseInt(els.citySelect.value);
  if (!cityId) {
    resetCityView();
    return;
  }

  state.currentCityId = cityId;
  const city = state.allCities.find((c) => c.city_id === cityId);

  // show city info card
  els.cityInfoCard.classList.remove("hidden");
  els.cityInfoName.textContent = `${city.city_name}, ${city.country}`;
  els.cityInfoDesc.textContent = city.description || "";
  els.cityPriceBadge.textContent =
    city.avg_hotel_price_low && city.avg_hotel_price_high
      ? `Avg. $${city.avg_hotel_price_low} – $${city.avg_hotel_price_high} / night`
      : "";

  els.initialPrompt.classList.add("hidden");
  els.hotelGrid.innerHTML =
    '<p style="color:var(--text-soft);padding:2rem 0">Loading hotels…</p>';
  els.resultsHeader.classList.add("hidden");
  els.emptyState.classList.add("hidden");

  state.currentHotels = await API.getHotelsByCity(cityId);
  applyFilters();
});

function resetCityView() {
  state.currentCityId = null;
  state.currentHotels = [];
  state.filteredHotels = [];
  els.cityInfoCard.classList.add("hidden");
  els.resultsHeader.classList.add("hidden");
  els.emptyState.classList.add("hidden");
  els.hotelGrid.innerHTML = "";
  els.initialPrompt.classList.remove("hidden");
}

// ── FILTERS ───────────────────────────────────────────────────────────────────

function applyFilters() {
  const minStars = parseInt(els.filterStars.value) || 0;
  const maxBudget = parseFloat(els.filterBudget.value) || Infinity;
  const restaurant = els.filterRestaurant.checked;
  const availOnly = els.filterAvailable.checked;

  state.filteredHotels = state.currentHotels.filter((h) => {
    if (h.star_rating < minStars) return false;
    if (h.price_per_night > maxBudget) return false;
    if (restaurant && h.restaurant_included !== 1) return false;
    if (availOnly && h.availability_status !== "available") return false;
    return true;
  });

  renderHotels(state.filteredHotels);
}

els.btnApplyFilters.addEventListener("click", applyFilters);

els.btnClearFilters.addEventListener("click", () => {
  els.filterStars.value = "";
  els.filterBudget.value = "";
  els.filterRestaurant.checked = false;
  els.filterAvailable.checked = true;
  applyFilters();
});

// ── HOTEL RENDERING ───────────────────────────────────────────────────────────

function renderHotels(hotels) {
  els.hotelGrid.innerHTML = "";
  els.resultsHeader.classList.remove("hidden");

  if (!hotels.length) {
    els.emptyState.classList.remove("hidden");
    els.resultsCount.textContent = "0 hotels found";
    return;
  }

  els.emptyState.classList.add("hidden");
  els.resultsCount.textContent = `${hotels.length} hotel${hotels.length !== 1 ? "s" : ""} found`;

  hotels.forEach((hotel) => {
    const card = buildHotelCard(hotel);
    els.hotelGrid.appendChild(card);
  });
}

function buildHotelCard(hotel) {
  const card = document.createElement("div");
  card.className = "hotel-card";

  const stars =
    "★".repeat(hotel.star_rating) + "☆".repeat(5 - hotel.star_rating);
  const isAvailable = hotel.availability_status === "available";
  const hasRestaurant = hotel.restaurant_included === 1;
  const isLoggedIn = !!state.currentUser;

  card.innerHTML = `
    <div class="hotel-card-header">
      <span class="hotel-status-badge ${isAvailable ? "status-available" : "status-unavailable"}">
        ${isAvailable ? "Available" : "Unavailable"}
      </span>
      <h3>${hotel.hotel_name}</h3>
      <p class="hotel-address">${hotel.address || ""}</p>
    </div>
    <div class="hotel-card-body">
      <div class="hotel-meta">
        <span class="stars" title="${hotel.star_rating} stars">${stars}</span>
        <span class="tag ${hasRestaurant ? "tag-restaurant" : "tag-no-restaurant"}">
          ${hasRestaurant ? "🍽 Restaurant" : "No restaurant"}
        </span>
      </div>
      <p class="hotel-desc">${hotel.description || ""}</p>
    </div>
    <div class="hotel-card-footer">
      <div class="hotel-price">$${hotel.price_per_night.toFixed(2)} <span>/ night</span></div>
      <button
        class="btn-reserve"
        data-hotel-id="${hotel.hotel_id}"
        ${!isLoggedIn || !isAvailable ? "disabled" : ""}
        title="${!isLoggedIn ? "Sign in to reserve" : !isAvailable ? "Not available" : "Reserve this hotel"}"
      >
        ${isLoggedIn ? "Reserve" : "Sign in"}
      </button>
    </div>
  `;

  // click card body → open detail modal
  card
    .querySelector(".hotel-card-body")
    .addEventListener("click", () => openDetailModal(hotel));
  card
    .querySelector(".hotel-card-header")
    .addEventListener("click", () => openDetailModal(hotel));

  // click reserve button
  const reserveBtn = card.querySelector(".btn-reserve");
  if (isLoggedIn && isAvailable) {
    reserveBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      openReserveModal(hotel);
    });
  } else if (!isLoggedIn) {
    reserveBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      openAuthModal("login");
    });
  }

  return card;
}

// ── DETAIL MODAL ──────────────────────────────────────────────────────────────

function openDetailModal(hotel) {
  const stars =
    "★".repeat(hotel.star_rating) + "☆".repeat(5 - hotel.star_rating);
  const city = state.allCities.find((c) => c.city_id === hotel.city_id);

  els.detailContent.innerHTML = `
    <div class="detail-header">
      <h2>${hotel.hotel_name}</h2>
      <p>${hotel.address || ""}</p>
    </div>
    <div class="detail-body">
      <div class="detail-row"><span class="detail-label">City</span><span>${city ? `${city.city_name}, ${city.country}` : "—"}</span></div>
      <div class="detail-row"><span class="detail-label">Stars</span><span>${stars}</span></div>
      <div class="detail-row"><span class="detail-label">Price / night</span><span>$${hotel.price_per_night.toFixed(2)}</span></div>
      <div class="detail-row"><span class="detail-label">Restaurant</span><span>${hotel.restaurant_included === 1 ? "Yes" : "No"}</span></div>
      <div class="detail-row"><span class="detail-label">Availability</span><span>${hotel.availability_status}</span></div>
      <p class="detail-desc">${hotel.description || ""}</p>
    </div>
  `;
  els.detailModal.classList.remove("hidden");
}

els.detailModalClose.addEventListener("click", () =>
  els.detailModal.classList.add("hidden"),
);
els.detailModal.addEventListener("click", (e) => {
  if (e.target === els.detailModal) els.detailModal.classList.add("hidden");
});

// ── RESERVATION MODAL ─────────────────────────────────────────────────────────

function openReserveModal(hotel) {
  state.selectedHotel = hotel;
  els.reserveHotelName.textContent = hotel.hotel_name;
  els.reserveCheckin.value = "";
  els.reserveCheckout.value = "";
  els.reserveGuests.value = 1;
  els.reserveSummary.classList.add("hidden");
  els.reserveError.classList.add("hidden");

  // set min date to today
  const today = new Date().toISOString().split("T")[0];
  els.reserveCheckin.min = today;
  els.reserveCheckout.min = today;

  els.reserveModal.classList.remove("hidden");
}

// live cost estimate as dates change
function updateReservationSummary() {
  const checkin = new Date(els.reserveCheckin.value);
  const checkout = new Date(els.reserveCheckout.value);
  if (
    !els.reserveCheckin.value ||
    !els.reserveCheckout.value ||
    checkout <= checkin
  ) {
    els.reserveSummary.classList.add("hidden");
    return;
  }
  const nights = Math.round((checkout - checkin) / 86400000);
  const total = (nights * state.selectedHotel.price_per_night).toFixed(2);
  els.reserveTotal.textContent = `$${total} (${nights} night${nights !== 1 ? "s" : ""})`;
  els.reserveSummary.classList.remove("hidden");
}

els.reserveCheckin.addEventListener("change", () => {
  // checkout must be after checkin
  els.reserveCheckout.min = els.reserveCheckin.value;
  updateReservationSummary();
});
els.reserveCheckout.addEventListener("change", updateReservationSummary);

els.reserveModalClose.addEventListener("click", () =>
  els.reserveModal.classList.add("hidden"),
);
els.reserveModal.addEventListener("click", (e) => {
  if (e.target === els.reserveModal) els.reserveModal.classList.add("hidden");
});

els.formReserve.addEventListener("submit", async (e) => {
  e.preventDefault();
  els.reserveError.classList.add("hidden");

  const checkin = els.reserveCheckin.value;
  const checkout = els.reserveCheckout.value;

  if (new Date(checkout) <= new Date(checkin)) {
    els.reserveError.textContent = "Check-out must be after check-in.";
    els.reserveError.classList.remove("hidden");
    return;
  }

  const result = await API.makeReservation({
    hotel_id: state.selectedHotel.hotel_id,
    check_in_date: checkin,
    check_out_date: checkout,
    number_of_guests: parseInt(els.reserveGuests.value),
    user_id: state.currentUser.user_id,
  });

  if (result.error) {
    els.reserveError.textContent = result.error;
    els.reserveError.classList.remove("hidden");
  } else {
    els.reserveModal.classList.add("hidden");
    alert(`Reservation confirmed! ID: ${result.reservation_id}`);
    // TODO: show a nicer confirmation UI instead of alert
  }
});

// ── INIT ──────────────────────────────────────────────────────────────────────

async function init() {
  // check if already logged in from a previous session
  const user = await API.me();
  if (user) setUser(user);
  await loadCities();
}

init();
