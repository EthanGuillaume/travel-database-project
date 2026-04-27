// app.js — frontend logic for TravelDatabase
// This file handles everything the user sees and does on the page.
// It talks to the Flask backend using fetch() to get data from the database.

// ── GLOBAL VARIABLES ──────────────────────────────────────────────────────────
// These store the current state of the app so different functions can use them.

let currentUser = null; // the logged-in user object, or null if not logged in
let allCities = []; // list of all cities, loaded once when the page opens
let currentHotels = []; // hotels for the city the user picked
let selectedHotel = null; // the hotel the user clicked "Reserve" on

// ── FETCH HELPERS ─────────────────────────────────────────────────────────────
// These functions talk to the Flask backend (app.py).
// To implement a route, add it to app.py — see the README for examples.

async function getCities() {
  const response = await fetch("/api/cities");
  return await response.json();
}

async function getHotelsByCity(cityId) {
  const response = await fetch("/api/cities/" + cityId + "/hotels");
  return await response.json();
}

async function loginUser(email, password) {
  const response = await fetch("/api/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email: email, password: password }),
  });
  return await response.json();
}

async function registerUser(username, email, password, budgetMin, budgetMax) {
  const response = await fetch("/api/auth/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      username: username,
      email: email,
      password: password,
      preferred_budget_min: budgetMin,
      preferred_budget_max: budgetMax,
    }),
  });
  return await response.json();
}

async function makeReservation(hotelId, checkin, checkout, guests, userId) {
  const response = await fetch("/api/reservations", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      hotel_id: hotelId,
      check_in_date: checkin,
      check_out_date: checkout,
      number_of_guests: guests,
      user_id: userId,
    }),
  });
  return await response.json();
}

async function getLoggedInUser() {
  const response = await fetch("/api/auth/me");
  if (response.ok) {
    return await response.json();
  }
  return null;
}

async function logoutUser() {
  await fetch("/api/auth/logout", { method: "POST" });
}

// ── AUTH: LOGIN / LOGOUT / SIGNUP ─────────────────────────────────────────────

function updateNavForUser(user) {
  // shows/hides the right buttons in the navbar depending on login state
  if (user) {
    document.getElementById("nav-auth-buttons").classList.add("hidden");
    document.getElementById("nav-user-info").classList.remove("hidden");
    document.getElementById("nav-username").textContent = user.username;
    document.getElementById("hero-note-guest").classList.add("hidden");
    document.getElementById("hero-note-user").classList.remove("hidden");
    document.getElementById("hero-note-user").textContent =
      "Welcome back, " +
      user.username +
      "! You can browse and make reservations.";
  } else {
    document.getElementById("nav-auth-buttons").classList.remove("hidden");
    document.getElementById("nav-user-info").classList.add("hidden");
    document.getElementById("hero-note-guest").classList.remove("hidden");
    document.getElementById("hero-note-user").classList.add("hidden");
  }

  // re-render hotel cards so the Reserve button updates correctly
  if (currentHotels.length > 0) {
    showHotels(getFilteredHotels());
  }
}

// open/close the login+signup modal
function openAuthModal(tab) {
  document.getElementById("auth-modal").classList.remove("hidden");
  switchTab(tab);
}
function closeAuthModal() {
  document.getElementById("auth-modal").classList.add("hidden");
}
function switchTab(tab) {
  if (tab === "login") {
    document.getElementById("form-login").classList.remove("hidden");
    document.getElementById("form-signup").classList.add("hidden");
    document.getElementById("tab-login").classList.add("active");
    document.getElementById("tab-signup").classList.remove("active");
  } else {
    document.getElementById("form-login").classList.add("hidden");
    document.getElementById("form-signup").classList.remove("hidden");
    document.getElementById("tab-login").classList.remove("active");
    document.getElementById("tab-signup").classList.add("active");
  }
}

document
  .getElementById("btn-open-login")
  .addEventListener("click", function () {
    openAuthModal("login");
  });
document
  .getElementById("btn-open-signup")
  .addEventListener("click", function () {
    openAuthModal("signup");
  });
document
  .getElementById("auth-modal-close")
  .addEventListener("click", closeAuthModal);
document.getElementById("tab-login").addEventListener("click", function () {
  switchTab("login");
});
document.getElementById("tab-signup").addEventListener("click", function () {
  switchTab("signup");
});

// close modal if user clicks outside of it
document.getElementById("auth-modal").addEventListener("click", function (e) {
  if (e.target === document.getElementById("auth-modal")) closeAuthModal();
});

document
  .getElementById("hero-signin-link")
  .addEventListener("click", function (e) {
    e.preventDefault();
    openAuthModal("login");
  });

document
  .getElementById("btn-logout")
  .addEventListener("click", async function () {
    await logoutUser();
    currentUser = null;
    updateNavForUser(null);
  });

document
  .getElementById("form-login")
  .addEventListener("submit", async function (e) {
    e.preventDefault();
    document.getElementById("login-error").classList.add("hidden");

    const email = document.getElementById("login-email").value;
    const password = document.getElementById("login-password").value;
    const result = await loginUser(email, password);

    if (result.error) {
      document.getElementById("login-error").textContent = result.error;
      document.getElementById("login-error").classList.remove("hidden");
    } else {
      currentUser = result;
      updateNavForUser(currentUser);
      closeAuthModal();
    }
  });

document
  .getElementById("form-signup")
  .addEventListener("submit", async function (e) {
    e.preventDefault();
    document.getElementById("signup-error").classList.add("hidden");

    const budgetMin =
      parseFloat(document.getElementById("signup-budget-min").value) || 0;
    const budgetMax =
      parseFloat(document.getElementById("signup-budget-max").value) || 0;

    if (budgetMax > 0 && budgetMax < budgetMin) {
      document.getElementById("signup-error").textContent =
        "Budget max must be greater than budget min.";
      document.getElementById("signup-error").classList.remove("hidden");
      return;
    }

    const result = await registerUser(
      document.getElementById("signup-username").value,
      document.getElementById("signup-email").value,
      document.getElementById("signup-password").value,
      budgetMin,
      budgetMax,
    );

    if (result.error) {
      document.getElementById("signup-error").textContent = result.error;
      document.getElementById("signup-error").classList.remove("hidden");
    } else {
      currentUser = result;
      updateNavForUser(currentUser);
      closeAuthModal();
    }
  });

// ── COUNTRY / CITY DROPDOWNS ──────────────────────────────────────────────────

async function loadCities() {
  allCities = await getCities();
  populateCountryDropdown();
}

function populateCountryDropdown() {
  const countrySet = new Set();
  for (let i = 0; i < allCities.length; i++) {
    countrySet.add(allCities[i].country);
  }

  const countries = Array.from(countrySet).sort();
  const countrySelect = document.getElementById("country-select");
  countrySelect.innerHTML = '<option value="">— Select a country —</option>';

  for (let i = 0; i < countries.length; i++) {
    const option = document.createElement("option");
    option.value = countries[i];
    option.textContent = countries[i];
    countrySelect.appendChild(option);
  }
}

document
  .getElementById("country-select")
  .addEventListener("change", function () {
    const country = this.value;
    const citySelect = document.getElementById("city-select");

    citySelect.innerHTML = '<option value="">— Select a city —</option>';
    citySelect.disabled = !country;

    if (!country) {
      resetView();
      return;
    }

    // filter cities to just the selected country
    const citiesInCountry = allCities.filter(function (c) {
      return c.country === country;
    });
    citiesInCountry.sort(function (a, b) {
      return a.city_name.localeCompare(b.city_name);
    });

    for (let i = 0; i < citiesInCountry.length; i++) {
      const option = document.createElement("option");
      option.value = citiesInCountry[i].city_id;
      option.textContent = citiesInCountry[i].city_name;
      citySelect.appendChild(option);
    }

    // if there's only one city in the country, auto-select it
    if (citiesInCountry.length === 1) {
      citySelect.value = citiesInCountry[0].city_id;
      citySelect.dispatchEvent(new Event("change"));
    }
  });

document
  .getElementById("city-select")
  .addEventListener("change", async function () {
    const cityId = parseInt(this.value);
    if (!cityId) {
      resetView();
      return;
    }

    const city = allCities.find(function (c) {
      return c.city_id === cityId;
    });

    // show the city info card above the hotel grid
    document.getElementById("city-info-card").classList.remove("hidden");
    document.getElementById("city-info-name").textContent =
      city.city_name + ", " + city.country;
    document.getElementById("city-info-desc").textContent =
      city.description || "";

    if (city.avg_hotel_price_low && city.avg_hotel_price_high) {
      document.getElementById("city-price-badge").textContent =
        "Avg. $" +
        city.avg_hotel_price_low +
        " – $" +
        city.avg_hotel_price_high +
        " / night";
    } else {
      document.getElementById("city-price-badge").textContent = "";
    }

    document.getElementById("initial-prompt").classList.add("hidden");
    document.getElementById("hotel-grid").innerHTML =
      '<p style="color:var(--text-soft);padding:2rem 0">Loading hotels…</p>';
    document.getElementById("results-header").classList.add("hidden");
    document.getElementById("empty-state").classList.add("hidden");

    currentHotels = await getHotelsByCity(cityId);
    showHotels(getFilteredHotels());
  });

function resetView() {
  currentHotels = [];
  document.getElementById("city-info-card").classList.add("hidden");
  document.getElementById("results-header").classList.add("hidden");
  document.getElementById("empty-state").classList.add("hidden");
  document.getElementById("hotel-grid").innerHTML = "";
  document.getElementById("initial-prompt").classList.remove("hidden");
}

// ── FILTERS ───────────────────────────────────────────────────────────────────

function getFilteredHotels() {
  const minStars = parseInt(document.getElementById("filter-stars").value) || 0;
  const maxBudget =
    parseFloat(document.getElementById("filter-budget").value) || Infinity;
  const needsRestaurant = document.getElementById("filter-restaurant").checked;
  const availableOnly = document.getElementById("filter-available").checked;

  const filtered = [];
  for (let i = 0; i < currentHotels.length; i++) {
    const hotel = currentHotels[i];
    if (hotel.star_rating < minStars) continue;
    if (hotel.price_per_night > maxBudget) continue;
    if (needsRestaurant && hotel.restaurant_included !== 1) continue;
    if (availableOnly && hotel.availability_status !== "available") continue;
    filtered.push(hotel);
  }
  return filtered;
}

document
  .getElementById("btn-apply-filters")
  .addEventListener("click", function () {
    showHotels(getFilteredHotels());
  });

document
  .getElementById("btn-clear-filters")
  .addEventListener("click", function () {
    document.getElementById("filter-stars").value = "";
    document.getElementById("filter-budget").value = "";
    document.getElementById("filter-restaurant").checked = false;
    document.getElementById("filter-available").checked = true;
    showHotels(getFilteredHotels());
  });

// ── HOTEL CARDS ───────────────────────────────────────────────────────────────

function showHotels(hotels) {
  const grid = document.getElementById("hotel-grid");
  grid.innerHTML = "";
  document.getElementById("results-header").classList.remove("hidden");

  if (hotels.length === 0) {
    document.getElementById("empty-state").classList.remove("hidden");
    document.getElementById("results-count").textContent = "0 hotels found";
    return;
  }

  document.getElementById("empty-state").classList.add("hidden");
  document.getElementById("results-count").textContent =
    hotels.length + " hotel" + (hotels.length !== 1 ? "s" : "") + " found";

  for (let i = 0; i < hotels.length; i++) {
    const card = buildHotelCard(hotels[i]);
    grid.appendChild(card);
  }
}

function buildHotelCard(hotel) {
  const card = document.createElement("div");
  card.className = "hotel-card";

  const starsFilled = "★".repeat(hotel.star_rating);
  const starsEmpty = "☆".repeat(5 - hotel.star_rating);
  const stars = starsFilled + starsEmpty;

  const isAvailable = hotel.availability_status === "available";
  const hasRestaurant = hotel.restaurant_included === 1;
  const isLoggedIn = currentUser !== null;

  const statusClass = isAvailable ? "status-available" : "status-unavailable";
  const statusText = isAvailable ? "Available" : "Unavailable";
  const restaurantTag = hasRestaurant
    ? '<span class="tag tag-restaurant">🍽 Restaurant</span>'
    : '<span class="tag tag-no-restaurant">No restaurant</span>';

  let reserveButtonDisabled = "";
  let reserveButtonTitle = "Reserve this hotel";
  let reserveButtonText = "Reserve";

  if (!isLoggedIn) {
    reserveButtonDisabled = "disabled";
    reserveButtonTitle = "Sign in to reserve";
    reserveButtonText = "Sign in";
  } else if (!isAvailable) {
    reserveButtonDisabled = "disabled";
    reserveButtonTitle = "Not available";
  }

  card.innerHTML =
    '<div class="hotel-card-header">' +
    '<span class="hotel-status-badge ' +
    statusClass +
    '">' +
    statusText +
    "</span>" +
    "<h3>" +
    hotel.hotel_name +
    "</h3>" +
    '<p class="hotel-address">' +
    (hotel.address || "") +
    "</p>" +
    "</div>" +
    '<div class="hotel-card-body">' +
    '<div class="hotel-meta">' +
    '<span class="stars">' +
    stars +
    "</span>" +
    restaurantTag +
    "</div>" +
    '<p class="hotel-desc">' +
    (hotel.description || "") +
    "</p>" +
    "</div>" +
    '<div class="hotel-card-footer">' +
    '<div class="hotel-price">$' +
    hotel.price_per_night.toFixed(2) +
    " <span>/ night</span></div>" +
    '<button class="btn-reserve" ' +
    reserveButtonDisabled +
    ' title="' +
    reserveButtonTitle +
    '">' +
    reserveButtonText +
    "</button>" +
    "</div>";

  // clicking the card header or body opens the detail popup
  card
    .querySelector(".hotel-card-header")
    .addEventListener("click", function () {
      openDetailModal(hotel);
    });
  card.querySelector(".hotel-card-body").addEventListener("click", function () {
    openDetailModal(hotel);
  });

  // clicking the reserve button
  const reserveBtn = card.querySelector(".btn-reserve");
  if (isLoggedIn && isAvailable) {
    reserveBtn.addEventListener("click", function (e) {
      e.stopPropagation();
      openReserveModal(hotel);
    });
  } else if (!isLoggedIn) {
    reserveBtn.addEventListener("click", function (e) {
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
  const city = allCities.find(function (c) {
    return c.city_id === hotel.city_id;
  });
  const cityText = city ? city.city_name + ", " + city.country : "—";

  document.getElementById("detail-content").innerHTML =
    '<div class="detail-header">' +
    "<h2>" +
    hotel.hotel_name +
    "</h2>" +
    "<p>" +
    (hotel.address || "") +
    "</p>" +
    "</div>" +
    '<div class="detail-body">' +
    '<div class="detail-row"><span class="detail-label">City</span><span>' +
    cityText +
    "</span></div>" +
    '<div class="detail-row"><span class="detail-label">Stars</span><span>' +
    stars +
    "</span></div>" +
    '<div class="detail-row"><span class="detail-label">Price / night</span><span>$' +
    hotel.price_per_night.toFixed(2) +
    "</span></div>" +
    '<div class="detail-row"><span class="detail-label">Restaurant</span><span>' +
    (hotel.restaurant_included === 1 ? "Yes" : "No") +
    "</span></div>" +
    '<div class="detail-row"><span class="detail-label">Availability</span><span>' +
    hotel.availability_status +
    "</span></div>" +
    '<p class="detail-desc">' +
    (hotel.description || "") +
    "</p>" +
    "</div>";

  document.getElementById("detail-modal").classList.remove("hidden");
}

document
  .getElementById("detail-modal-close")
  .addEventListener("click", function () {
    document.getElementById("detail-modal").classList.add("hidden");
  });
document.getElementById("detail-modal").addEventListener("click", function (e) {
  if (e.target === document.getElementById("detail-modal")) {
    document.getElementById("detail-modal").classList.add("hidden");
  }
});

// ── RESERVATION MODAL ─────────────────────────────────────────────────────────

function openReserveModal(hotel) {
  selectedHotel = hotel;

  document.getElementById("reserve-hotel-name").textContent = hotel.hotel_name;
  document.getElementById("reserve-checkin").value = "";
  document.getElementById("reserve-checkout").value = "";
  document.getElementById("reserve-guests").value = 1;
  document.getElementById("reserve-summary").classList.add("hidden");
  document.getElementById("reserve-error").classList.add("hidden");

  const today = new Date().toISOString().split("T")[0];
  document.getElementById("reserve-checkin").min = today;
  document.getElementById("reserve-checkout").min = today;

  document.getElementById("reserve-modal").classList.remove("hidden");
}

function updateReservationSummary() {
  const checkin = document.getElementById("reserve-checkin").value;
  const checkout = document.getElementById("reserve-checkout").value;

  if (!checkin || !checkout || new Date(checkout) <= new Date(checkin)) {
    document.getElementById("reserve-summary").classList.add("hidden");
    return;
  }

  const nights = Math.round(
    (new Date(checkout) - new Date(checkin)) / 86400000,
  );
  const total = (nights * selectedHotel.price_per_night).toFixed(2);
  document.getElementById("reserve-total").textContent =
    "$" + total + " (" + nights + " night" + (nights !== 1 ? "s" : "") + ")";
  document.getElementById("reserve-summary").classList.remove("hidden");
}

document
  .getElementById("reserve-checkin")
  .addEventListener("change", function () {
    document.getElementById("reserve-checkout").min = this.value;
    updateReservationSummary();
  });
document
  .getElementById("reserve-checkout")
  .addEventListener("change", updateReservationSummary);

document
  .getElementById("reserve-modal-close")
  .addEventListener("click", function () {
    document.getElementById("reserve-modal").classList.add("hidden");
  });
document
  .getElementById("reserve-modal")
  .addEventListener("click", function (e) {
    if (e.target === document.getElementById("reserve-modal")) {
      document.getElementById("reserve-modal").classList.add("hidden");
    }
  });

document
  .getElementById("form-reserve")
  .addEventListener("submit", async function (e) {
    e.preventDefault();
    document.getElementById("reserve-error").classList.add("hidden");

    const checkin = document.getElementById("reserve-checkin").value;
    const checkout = document.getElementById("reserve-checkout").value;

    if (new Date(checkout) <= new Date(checkin)) {
      document.getElementById("reserve-error").textContent =
        "Check-out must be after check-in.";
      document.getElementById("reserve-error").classList.remove("hidden");
      return;
    }

    const result = await makeReservation(
      selectedHotel.hotel_id,
      checkin,
      checkout,
      parseInt(document.getElementById("reserve-guests").value),
      currentUser.user_id,
    );

    if (result.error) {
      document.getElementById("reserve-error").textContent = result.error;
      document.getElementById("reserve-error").classList.remove("hidden");
    } else {
      document.getElementById("reserve-modal").classList.add("hidden");
      alert("Reservation confirmed! ID: " + result.reservation_id);
    }
  });

// ── START ─────────────────────────────────────────────────────────────────────
// This runs when the page loads. It checks if someone is already logged in
// and loads the city list from the database.

async function init() {
  currentUser = await getLoggedInUser();
  updateNavForUser(currentUser);
  await loadCities();
}

init();
