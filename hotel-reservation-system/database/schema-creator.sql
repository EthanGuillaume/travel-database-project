-- schema-creator.sql
-- Hotel Reservation System - Full Local Database Setup
-- Run once to create your local database, tables, and seed data.
--
-- Requirements: MySQL 8.0+
-- Usage:
--   mysql -u root -p < schema-creator.sql
--
-- Each developer runs this once on their own machine.
-- It creates (or re-creates) the 'hotel_reservation_db' database.

-- ============================================================
-- 1. DATABASE
-- ============================================================
DROP DATABASE IF EXISTS hotel_reservation_db;
CREATE DATABASE hotel_reservation_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hotel_reservation_db;

-- ============================================================
-- 2. TABLES  (same DDL as schema.sql)
-- ============================================================
CREATE TABLE users (
    user_id   INT PRIMARY KEY,
    username  VARCHAR(50)  NOT NULL,
    user_type VARCHAR(20)  NOT NULL,
    CONSTRAINT chk_user_type CHECK (user_type IN ('registered', 'guest'))
);

CREATE TABLE city (
    city_id              INT PRIMARY KEY,
    city_name            VARCHAR(50)    NOT NULL,
    country              VARCHAR(50),
    region               VARCHAR(50),
    description          VARCHAR(200),
    avg_hotel_price_low  DECIMAL(10,2),
    avg_hotel_price_high DECIMAL(10,2),
    CONSTRAINT chk_price_low  CHECK (avg_hotel_price_low  >= 0),
    CONSTRAINT chk_price_high CHECK (avg_hotel_price_high >= avg_hotel_price_low)
);

CREATE TABLE hotel (
    hotel_id            INT PRIMARY KEY,
    hotel_name          VARCHAR(100)   NOT NULL,
    address             VARCHAR(200),
    price_per_night     DECIMAL(10,2),
    star_rating         INT,
    restaurant_included TINYINT(1),
    description         VARCHAR(200),
    availability_status VARCHAR(20),
    city_id             INT,
    FOREIGN KEY (city_id) REFERENCES city(city_id),
    CONSTRAINT chk_hotel_price  CHECK (price_per_night     >= 0),
    CONSTRAINT chk_star_rating  CHECK (star_rating         BETWEEN 1 AND 5),
    CONSTRAINT chk_restaurant   CHECK (restaurant_included IN (0,1)),
    CONSTRAINT chk_avail_status CHECK (availability_status IN ('available','unavailable'))
);

CREATE TABLE registered_user (
    user_id              INT PRIMARY KEY,
    email                VARCHAR(100)   NOT NULL UNIQUE,
    password_hash        VARCHAR(100)   NOT NULL,
    preferred_budget_min DECIMAL(10,2),
    preferred_budget_max DECIMAL(10,2),
    availability_start   DATE,
    availability_end     DATE,
    preferred_city_id    INT,
    FOREIGN KEY (user_id)           REFERENCES users(user_id),
    FOREIGN KEY (preferred_city_id) REFERENCES city(city_id),
    CONSTRAINT chk_budget_min  CHECK (preferred_budget_min >= 0),
    CONSTRAINT chk_budget_max  CHECK (preferred_budget_max >= preferred_budget_min),
    CONSTRAINT chk_avail_dates CHECK (availability_end >= availability_start)
);

CREATE TABLE guest_user (
    user_id          INT PRIMARY KEY,
    browse_only_flag TINYINT(1),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT chk_browse_flag CHECK (browse_only_flag IN (0,1))
);

CREATE TABLE reservation (
    reservation_id     INT PRIMARY KEY,
    check_in_date      DATE          NOT NULL,
    check_out_date     DATE          NOT NULL,
    number_of_guests   INT,
    total_cost         DECIMAL(10,2),
    reservation_status VARCHAR(20),
    user_id            INT,
    hotel_id           INT,
    FOREIGN KEY (user_id)  REFERENCES registered_user(user_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id),
    CONSTRAINT chk_guests     CHECK (number_of_guests   >  0),
    CONSTRAINT chk_total_cost CHECK (total_cost         >= 0),
    CONSTRAINT chk_res_status CHECK (reservation_status IN ('pending','confirmed','cancelled')),
    CONSTRAINT chk_dates      CHECK (check_out_date     >  check_in_date)
);

-- ============================================================
-- 3. SEED DATA — European Capital Cities (44 capitals)
--    city_id, city_name, country, region, description,
--    avg_hotel_price_low, avg_hotel_price_high
-- ============================================================
INSERT INTO city VALUES
(1,  'Amsterdam',    'Netherlands',      'Western Europe',   'Canal-ringed capital known for narrow houses and world-class museums.',         100.00, 250.00),
(2,  'Andorra la Vella','Andorra',       'Southern Europe',  'High-altitude capital nestled in the Pyrenees mountains.',                       60.00, 140.00),
(3,  'Athens',       'Greece',           'Southern Europe',  'Ancient city, birthplace of democracy and home of the Acropolis.',               70.00, 180.00),
(4,  'Belgrade',     'Serbia',           'Southeastern Europe','Vibrant city at the confluence of the Sava and Danube rivers.',                45.00, 120.00),
(5,  'Berlin',       'Germany',          'Central Europe',   'Dynamic capital renowned for history, culture, and nightlife.',                  80.00, 200.00),
(6,  'Bern',         'Switzerland',      'Western Europe',   'Medieval old town capital beside the River Aare.',                              120.00, 300.00),
(7,  'Bratislava',   'Slovakia',         'Central Europe',   'Compact capital on the Danube with a well-preserved old town.',                  50.00, 130.00),
(8,  'Brussels',     'Belgium',          'Western Europe',   'Heart of Europe, home to EU institutions and Art Nouveau architecture.',          90.00, 220.00),
(9,  'Bucharest',    'Romania',          'Eastern Europe',   'City of contrasts blending Belle Epoque elegance with communist-era boulevards.',  40.00, 110.00),
(10, 'Budapest',     'Hungary',          'Central Europe',   'Capital split by the Danube, famed for thermal baths and grand architecture.',    50.00, 140.00),
(11, 'Chisinau',     'Moldova',          'Eastern Europe',   'Green, leafy capital with Soviet-era architecture and wine culture.',             25.00,  70.00),
(12, 'Copenhagen',   'Denmark',          'Northern Europe',  'Sustainable, design-forward capital with colorful Nyhavn harbour.',             130.00, 320.00),
(13, 'Dublin',       'Ireland',          'Northern Europe',  'Lively capital on the River Liffey, famous for pubs and Georgian squares.',      100.00, 260.00),
(14, 'Helsinki',     'Finland',          'Northern Europe',  'Compact coastal capital known for design, saunas, and sea fortresses.',           90.00, 230.00),
(15, 'Kyiv',         'Ukraine',          'Eastern Europe',   'Ancient city on the Dnipro River, rich in Orthodox churches and history.',        30.00,  90.00),
(16, 'Lisbon',       'Portugal',         'Southern Europe',  'Hilly coastal capital with pastel buildings, trams, and Atlantic cuisine.',       70.00, 180.00),
(17, 'Ljubljana',    'Slovenia',         'Central Europe',   'Charming riverside capital with a pedestrian old town and hilltop castle.',       60.00, 150.00),
(18, 'London',       'United Kingdom',   'Western Europe',   'Iconic global city on the Thames, world leader in culture and finance.',         150.00, 400.00),
(19, 'Luxembourg City','Luxembourg',     'Western Europe',   'Dramatic fortified capital straddling deep gorges.',                            130.00, 280.00),
(20, 'Madrid',       'Spain',            'Southern Europe',  'Vibrant capital at the heart of the Iberian Peninsula, home to the Prado.',       80.00, 210.00),
(21, 'Minsk',        'Belarus',          'Eastern Europe',   'Stalinist-architecture capital largely rebuilt after World War II.',              25.00,  70.00),
(22, 'Monaco',       'Monaco',           'Southern Europe',  'Glamorous microstate on the French Riviera famed for casinos and F1.',           250.00, 600.00),
(23, 'Nicosia',      'Cyprus',           'Southern Europe',  'Last divided capital city in the world, rich in Byzantine heritage.',             55.00, 140.00),
(24, 'Oslo',         'Norway',           'Northern Europe',  'Fjord-side capital surrounded by forests, known for Vikings and Munch.',         140.00, 340.00),
(25, 'Paris',        'France',           'Western Europe',   'City of Light renowned for the Eiffel Tower, haute cuisine, and fashion.',       130.00, 380.00),
(26, 'Podgorica',    'Montenegro',       'Southeastern Europe','Modern capital close to Lake Skadar and the Adriatic coast.',                   35.00,  95.00),
(27, 'Prague',       'Czech Republic',   'Central Europe',   'Fairy-tale city on the Vltava River, famed for its medieval Old Town.',          60.00, 160.00),
(28, 'Reykjavik',    'Iceland',          'Northern Europe',  'World''s northernmost capital, gateway to Northern Lights and geysers.',         120.00, 290.00),
(29, 'Riga',         'Latvia',           'Northern Europe',  'Art Nouveau gem on the Baltic Sea with a UNESCO-listed old town.',                50.00, 130.00),
(30, 'Rome',         'Italy',            'Southern Europe',  'Eternal City layered with millennia of history, art, and gastronomy.',           100.00, 280.00),
(31, 'San Marino',   'San Marino',       'Southern Europe',  'Historic hilltop microstate overlooking the Adriatic.',                           70.00, 160.00),
(32, 'Sarajevo',     'Bosnia & Herzegovina','Southeastern Europe','Multicultural mountain capital where East meets West.',                      35.00, 100.00),
(33, 'Skopje',       'North Macedonia',  'Southeastern Europe','Capital undergoing bold urban transformation along the Vardar River.',          30.00,  85.00),
(34, 'Sofia',        'Bulgaria',         'Southeastern Europe','One of Europe''s oldest capitals, ringed by the Vitosha mountain.',             35.00, 100.00),
(35, 'Stockholm',    'Sweden',           'Northern Europe',  'Elegant capital spread across 14 islands where Lake Malaren meets the sea.',     120.00, 300.00),
(36, 'Tallinn',      'Estonia',          'Northern Europe',  'Best-preserved medieval old town on the Baltic, a UNESCO World Heritage site.',   55.00, 145.00),
(37, 'Tirana',       'Albania',          'Southeastern Europe','Colourful, rapidly modernising capital in the shadow of Mount Dajti.',          25.00,  75.00),
(38, 'Vaduz',        'Liechtenstein',    'Central Europe',   'Tiny Rhine-valley capital dominated by a medieval hilltop castle.',              100.00, 220.00),
(39, 'Valletta',     'Malta',            'Southern Europe',  'Smallest EU capital, a baroque fortress city and UNESCO World Heritage site.',    70.00, 180.00),
(40, 'Vatican City', 'Vatican City',     'Southern Europe',  'Smallest country in the world, home to St. Peter''s Basilica and the Sistine Chapel.', 180.00, 420.00),
(41, 'Vienna',       'Austria',          'Central Europe',   'Imperial capital of coffee houses, opera, and grand Ringstrasse palaces.',       100.00, 270.00),
(42, 'Vilnius',      'Lithuania',        'Northern Europe',  'Baroque old town capital with the largest medieval old town in the Baltics.',     50.00, 130.00),
(43, 'Warsaw',       'Poland',           'Central Europe',   'Resilient capital meticulously reconstructed after WWII destruction.',            55.00, 150.00),
(44, 'Zagreb',       'Croatia',          'Central Europe',   'Upper and lower town capital with excellent museums and cafe culture.',           55.00, 145.00);

-- ============================================================
-- 4. SEED DATA — 2 Hotels per Capital City (88 hotels total)
--    hotel_id, hotel_name, address, price_per_night,
--    star_rating, restaurant_included, description,
--    availability_status, city_id
-- ============================================================
INSERT INTO hotel VALUES
-- Amsterdam (city_id=1)
(1,  'Hotel V Nesplein',          'Nes 49, Amsterdam',                          150.00, 4, 1, 'Stylish boutique hotel in the heart of Amsterdam near the Dam Square.',          'available',   1),
(2,  'Mauro Mansion',             'Herengracht 51, Amsterdam',                  220.00, 5, 1, 'Luxury canal-house hotel in a UNESCO-listed 17th-century Amsterdam mansion.',      'available',   1),
-- Andorra la Vella (city_id=2)
(3,  'Hotel Cervol',              'Carrer de la Roda 1, Andorra la Vella',       75.00, 3, 1, 'Comfortable city-centre hotel close to the main shopping boulevard.',             'available',   2),
(4,  'Sport Hotel Village',       'Carrer del Batlle Pere Moles, Andorra',      110.00, 4, 1, 'Mountain resort hotel with spa and easy access to Grandvalira slopes.',           'available',   2),
-- Athens (city_id=3)
(5,  'Hotel Grande Bretagne',     'Syntagma Square, Athens',                    200.00, 5, 1, 'Grand neoclassical landmark with views of the Parthenon and Constitution Square.', 'available',   3),
(6,  'Electra Metropolis Athens', 'Mitropoleos 15, Athens',                     120.00, 5, 1, 'Contemporary design hotel steps from Monastiraki flea market.',                   'available',   3),
-- Belgrade (city_id=4)
(7,  'Square Nine Hotel',         'Studentski Trg 9, Belgrade',                  85.00, 5, 1, 'Award-winning luxury boutique hotel on a historic Belgrade square.',              'available',   4),
(8,  'Hotel Moskva',              'Balkanska 1, Belgrade',                        55.00, 4, 1, 'Iconic 1906 Secession-style landmark hotel at the heart of Belgrade.',            'available',   4),
-- Berlin (city_id=5)
(9,  'Hotel de Rome',             'Behrenstrasse 37, Berlin',                   180.00, 5, 1, 'Luxurious five-star hotel in a former Dresdner Bank building near Unter den Linden.','available', 5),
(10, 'Michelberger Hotel',        'Warschauer Strasse 39-40, Berlin',             90.00, 3, 1, 'Creative neighbourhood hotel in Friedrichshain beloved by artists and musicians.', 'available',   5),
-- Bern (city_id=6)
(11, 'Bellevue Palace Bern',      'Kochergasse 3-5, Bern',                      260.00, 5, 1, 'Grand state hotel overlooking the Alps, hosting heads of state since 1913.',      'available',   6),
(12, 'Hotel Kreuz Bern',          'Zeughausgasse 41, Bern',                     130.00, 4, 1, 'Comfortable renovated hotel in the UNESCO old town centre.',                      'available',   6),
-- Bratislava (city_id=7)
(13, 'Hotel Marrol''s',           'Tobrucka 4, Bratislava',                      95.00, 5, 1, 'Intimate boutique hotel in an Edwardian townhouse steps from Old Town.',          'available',   7),
(14, 'Radisson Blu Carlton Hotel','Hviezdoslavovo Nam 3, Bratislava',             80.00, 5, 1, 'Five-star property on the city''s most beautiful square near the Danube.',        'available',   7),
-- Brussels (city_id=8)
(15, 'Hotel Le Plaza Brussels',   'Boulevard A. Max 118-126, Brussels',         140.00, 5, 1, 'Opulent Art Deco palace hotel a short walk from the Grand Place.',                'available',   8),
(16, 'Pillows Grand Hotel Place Rouppe','Place Rouppe 17, Brussels',            100.00, 4, 1, 'Elegant hotel in a renovated historical building in central Brussels.',           'available',   8),
-- Bucharest (city_id=9)
(17, 'Grand Hotel Continental',   'Calea Victoriei 56, Bucharest',               70.00, 5, 1, 'Historic five-star hotel on the Avenue of Victory in downtown Bucharest.',        'available',   9),
(18, 'Hotel Epoque',              'Strada Ion Campineanu 19, Bucharest',          60.00, 5, 1, 'Boutique Art Deco hotel combining 1930s glamour with modern luxury.',              'available',   9),
-- Budapest (city_id=10)
(19, 'Four Seasons Hotel Gresham Palace','Roosevelt Ter 5-6, Budapest',         280.00, 5, 1, 'Breathtaking Art Nouveau palace overlooking the Chain Bridge.',                   'available',  10),
(20, 'Danubius Hotel Gellert',    'Szent Gellert Ter 1, Budapest',               90.00, 4, 1, 'Legendary spa hotel with thermal baths at the foot of Gellert Hill.',             'available',  10),
-- Chisinau (city_id=11)
(21, 'Nobil Luxury Boutique Hotel','Mitropolit Dosoftei 81, Chisinau',           55.00, 5, 1, 'Leading luxury property in the Moldovan capital with refined interiors.',         'available',  11),
(22, 'Hotel Jolly Alon',          'Bulevardul Negruzzi 7, Chisinau',             35.00, 4, 1, 'Centrally located hotel offering comfortable rooms near Stefan cel Mare park.',    'available',  11),
-- Copenhagen (city_id=12)
(23, 'Hotel D''Angleterre',       'Kongens Nytorv 34, Copenhagen',              300.00, 5, 1, 'Grand dame of Copenhagen hotels, open since 1755 on the Royal Square.',           'available',  12),
(24, 'Nimb Hotel',                'Bernstorffsgade 5, Copenhagen',               220.00, 5, 1, 'Romantic Moorish-style boutique hotel overlooking Tivoli Gardens.',               'available',  12),
-- Dublin (city_id=13)
(25, 'The Shelbourne Dublin',     'St. Stephen''s Green, Dublin',               200.00, 5, 1, 'Landmark Georgian hotel on St. Stephen''s Green since 1824.',                     'available',  13),
(26, 'The Merrion Hotel',         'Upper Merrion Street, Dublin',               240.00, 5, 1, 'Five-star hotel in four restored Georgian town houses beside Government buildings.','available', 13),
-- Helsinki (city_id=14)
(27, 'Hotel Katajanokka',         'Merikasarminkatu 1a, Helsinki',               115.00, 4, 1, 'Unique hotel in a converted 1888 prison building on the Katajanokka peninsula.',  'available',  14),
(28, 'Hotel Haven',               'Unioninkatu 17, Helsinki',                    170.00, 5, 1, 'Intimate harbour-side luxury hotel with a Michelin-recommended restaurant.',      'available',  14),
-- Kyiv (city_id=15)
(29, 'InterContinental Kyiv',     'Velyka Zhytomyrska 2a, Kyiv',                 80.00, 5, 1, 'Luxury high-rise hotel with panoramic views of St. Sophia''s Cathedral.',         'available',  15),
(30, 'Premier Palace Hotel',      'Tarasa Shevchenka Blvd 5-7/29, Kyiv',         50.00, 5, 1, 'Grand early-20th-century palace hotel in the heart of the Ukrainian capital.',    'available',  15),
-- Lisbon (city_id=16)
(31, 'Bairro Alto Hotel',         'Praca Luis de Camoes 2, Lisbon',             150.00, 5, 1, 'Original design hotel in an 18th-century building in historic Bairro Alto.',      'available',  16),
(32, 'Memmo Alfama',              'Travessa Merceeiras 27, Lisbon',              100.00, 4, 1, 'Boutique hotel with an infinity pool and sweeping views over the Alfama.',        'available',  16),
-- Ljubljana (city_id=17)
(33, 'Grand Hotel Union',         'Miklosiceva Cesta 1, Ljubljana',              95.00, 4, 1, 'Art Nouveau landmark on Republic Square, the pride of Slovenian hospitality.',    'available',  17),
(34, 'Vander Urbani Resort',      'Krojaška Ulica 6-8, Ljubljana',               85.00, 4, 1, 'Boutique design hotel conversion of four 18th-century town houses by the river.',  'available',  17),
-- London (city_id=18)
(35, 'The Savoy',                 'Strand, London',                             350.00, 5, 1, 'Iconic Thames-side Art Deco and Edwardian luxury hotel open since 1889.',          'available',  18),
(36, 'The Hoxton Shoreditch',     'Shoreditch High Street, London',             160.00, 4, 1, 'Cool design hotel in the heart of East London''s creative quarter.',               'available',  18),
-- Luxembourg City (city_id=19)
(37, 'Hotel Le Royal Luxembourg', 'Boulevard Royal 12, Luxembourg',             200.00, 5, 1, 'Five-star hotel in the financial district with a renowned spa and restaurant.',   'available',  19),
(38, 'Sofitel Luxembourg Europe', 'Rue le Fosse 4, Luxembourg',                 150.00, 5, 1, 'Chic contemporary hotel near the European institutions.',                         'available',  19),
-- Madrid (city_id=20)
(39, 'Hotel Ritz Madrid',         'Plaza de la Lealtad 5, Madrid',             280.00, 5, 1, 'Palace-era landmark hotel next to the Prado, a Madrid institution since 1910.',   'available',  20),
(40, 'Only YOU Hotel Atocha',     'Paseo Infanta Isabel 13, Madrid',            120.00, 4, 1, 'Design-forward lifestyle hotel steps from Atocha station and the Reina Sofia.',   'available',  20),
-- Minsk (city_id=21)
(41, 'Hotel Europe Minsk',        'Internatsionalnaya 25, Minsk',                50.00, 5, 1, 'Historical five-star hotel in the very centre of the Belarusian capital.',        'available',  21),
(42, 'Crowne Plaza Minsk',        'Komsomolskaya 6, Minsk',                      45.00, 4, 1, 'International brand hotel beside Victory Square with modern amenities.',          'available',  21),
-- Monaco (city_id=22)
(43, 'Hotel de Paris Monte-Carlo','Place du Casino, Monaco',                   500.00, 5, 1, 'Belle Epoque palace overlooking the Casino Square, a Riviera icon since 1863.',   'available',  22),
(44, 'Fairmont Monte Carlo',      'Avenue des Spelugues 12, Monaco',            350.00, 5, 1, 'Glamorous cliffside resort hotel built over the Mediterranean Sea.',               'available',  22),
-- Nicosia (city_id=23)
(45, 'Hilton Nicosia',            'Archbishop Makarios 3 Ave, Nicosia',          90.00, 5, 1, 'Flagship five-star hotel in the new city with a rooftop pool.',                  'available',  23),
(46, 'Classic Hotel Nicosia',     'Rigainis 94, Nicosia',                        60.00, 3, 1, 'Comfortable budget-friendly hotel in a quiet street near the old city walls.',    'available',  23),
-- Oslo (city_id=24)
(47, 'The Thief',                 'Landgangen 1, Oslo',                         220.00, 5, 1, 'Contemporary art hotel on Tjuvholmen peninsula with a private beach.',            'available',  24),
(48, 'Grand Hotel Oslo',          'Karl Johans Gate 31, Oslo',                  180.00, 5, 1, 'Legendary 19th-century hotel where Henrik Ibsen was a regular guest.',            'available',  24),
-- Paris (city_id=25)
(49, 'Le Bristol Paris',          'Rue du Faubourg Saint-Honore 112, Paris',    500.00, 5, 1, 'Palace hotel on the most prestigious shopping street in the world.',              'available',  25),
(50, 'Hotel Monge',               'Rue Monge 55, Paris',                        130.00, 4, 1, 'Intimate boutique hotel in the Latin Quarter steps from the Jardin des Plantes.', 'available',  25),
-- Podgorica (city_id=26)
(51, 'Hilton Podgorica Crna Gora','Bulevar Svetog Petra Cetinjskog 2, Podgorica', 90.00, 5, 1, 'Modern five-star hotel on the main boulevard in central Podgorica.',             'available',  26),
(52, 'Hotel Kerber',              'Moskovska 69, Podgorica',                     45.00, 3, 1, 'Well-located three-star hotel popular with business travellers.',                 'available',  26),
-- Prague (city_id=27)
(53, 'Hotel Paris Prague',        'U Obecniho Domu 1, Prague',                  120.00, 5, 1, 'Neo-Gothic Art Nouveau masterpiece adjacent to the Municipal House.',             'available',  27),
(54, 'Mosaic House Prague',       'Odboru 4, Prague',                             65.00, 3, 1, 'Award-winning design hostel-hotel hybrid in the Nusle neighbourhood.',            'available',  27),
-- Reykjavik (city_id=28)
(55, 'Hotel Borg',                'Posthusstraeti 11, Reykjavik',               200.00, 4, 1, 'Art Deco landmark overlooking the Parliament square since 1930.',                 'available',  28),
(56, 'Ion City Hotel',            'Laugavegur 28, Reykjavik',                   130.00, 4, 1, 'Stylish boutique hotel on the main shopping street close to Hallgrimskirkja.',   'available',  28),
-- Riga (city_id=29)
(57, 'Grand Hotel Kempinski Riga','Aspazijas Bulvaris 22, Riga',               160.00, 5, 1, 'Luxury hotel overlooking the Freedom Monument in the heart of Riga.',             'available',  29),
(58, 'Hotel Bergs',               'Elizabetes Iela 83-85, Riga',                100.00, 5, 1, 'Stylish boutique hotel in a landmark Art Nouveau building in the quiet centre.',  'available',  29),
-- Rome (city_id=30)
(59, 'Hotel de Russie',           'Via del Babuino 9, Rome',                    350.00, 5, 1, 'Iconic five-star retreat between Piazza del Popolo and the Spanish Steps.',       'available',  30),
(60, 'Palazzo Manfredi',          'Via Labicana 125, Rome',                     200.00, 5, 1, 'Boutique hotel with a rooftop restaurant directly opposite the Colosseum.',       'available',  30),
-- San Marino (city_id=31)
(61, 'Hotel Titano',              'Contrada del Collegio 31, San Marino',        90.00, 3, 1, 'Traditional hotel in the historic centre with panoramic terrace views.',           'available',  31),
(62, 'Hotel Cesare',              'Via Donna Felicissima 16, San Marino',        70.00, 3, 0, 'Family-run hotel offering comfortable rooms near the Third Tower.',               'available',  31),
-- Sarajevo (city_id=32)
(63, 'Hotel Europe Sarajevo',     'Julija Dzerzinskoga 5, Sarajevo',             65.00, 4, 1, 'Austro-Hungarian landmark hotel in the pedestrian heart of Sarajevo.',            'available',  32),
(64, 'Hotel Astra Garni',         'Zelenih Beretki 9, Sarajevo',                 40.00, 3, 0, 'Cosy budget-friendly hotel in the Bascarsija old bazaar quarter.',                'available',  32),
-- Skopje (city_id=33)
(65, 'DoubleTree by Hilton Skopje','Str. Nikola Vapcarov 2, Skopje',            70.00, 5, 1, 'Contemporary five-star hotel on the Vardar River with a rooftop pool.',           'available',  33),
(66, 'Hotel Arka',                'Kosta Novakovikj bb, Skopje',                 45.00, 4, 1, 'Comfortable business hotel within walking distance of the Old Bazaar.',           'available',  33),
-- Sofia (city_id=34)
(67, 'Sofia Hotel Balkan',        'Sveta Nedelya 5, Sofia',                      85.00, 5, 1, 'Grand historic hotel on the central square, a Sofia institution since 1955.',     'available',  34),
(68, 'Hotel Les Fleurs',          'Vitosha Blvd 21, Sofia',                      50.00, 4, 1, 'Elegant boutique hotel in a 19th-century building on the main pedestrian street.','available',  34),
-- Stockholm (city_id=35)
(69, 'Grand Hotel Stockholm',     'Sodra Blasieholmshamnen 8, Stockholm',       260.00, 5, 1, 'Legendary waterfront hotel facing the Royal Palace, home of the Nobel banquet.',  'available',  35),
(70, 'Hotel Skeppsholmen',        'Gröna Gangen 1, Stockholm',                  150.00, 4, 1, 'Design hotel on the museum island of Skeppsholmen in central Stockholm.',         'available',  35),
-- Tallinn (city_id=36)
(71, 'Hotel Telegraaf',           'Vene 9, Tallinn',                            110.00, 5, 1, 'Luxury hotel converted from the 1888 Tallinn central telegraph office.',          'available',  36),
(72, 'Hotel Schlossle',           'Puhavaimu 13-15, Tallinn',                    90.00, 5, 1, 'Intimate medieval hotel in a cluster of 15th-century merchant houses.',           'available',  36),
-- Tirana (city_id=37)
(73, 'Hotel Tirana International','Sheshi Skenderbej, Tirana',                   50.00, 4, 1, 'Centrally located hotel overlooking Skanderbeg Square since 1979.',              'available',  37),
(74, 'Rogner Hotel Tirana',       'Bulevardi Deshmoret e Kombit, Tirana',        55.00, 4, 1, 'Lush garden hotel on the main boulevard close to the National History Museum.',  'available',  37),
-- Vaduz (city_id=38)
(75, 'Park-Hotel Sonnenhof',      'Mareestrasse 29, Vaduz',                     160.00, 4, 1, 'Family-run luxury hotel with mountain views above the Rhine valley.',             'available',  38),
(76, 'Hotel Real',                'Städtle 21, Vaduz',                           100.00, 3, 1, 'Central hotel steps from the National Art Museum and Vaduz Castle trail.',       'available',  38),
-- Valletta (city_id=39)
(77, 'The Phoenicia Malta',       'The Mall, Floriana, Valletta',               140.00, 5, 1, 'Elegant 1940s colonial hotel with formal gardens at Valletta''s grand entrance.',  'available',  39),
(78, 'Rosselli AX Privilege',     'St John Street 10, Valletta',                110.00, 5, 1, 'Boutique hotel in a 16th-century palazzo near St John''s Co-Cathedral.',         'available',  39),
-- Vatican City (city_id=40)
(79, 'Hotel Columbus',            'Via della Conciliazione 33, Vatican City',   180.00, 4, 1, 'Palazzo hotel a hundred metres from St. Peter''s Square.',                       'available',  40),
(80, 'Residenza Paolo VI',        'Via Paolo VI 29, Vatican City',              200.00, 4, 1, 'Exclusive residence directly overlooking St. Peter''s Square.',                  'available',  40),
-- Vienna (city_id=41)
(81, 'Hotel Sacher Wien',         'Philharmoniker Str. 4, Vienna',              280.00, 5, 1, 'Legendary five-star hotel famed for the original Sachertorte, open since 1876.',  'available',  41),
(82, 'Hotel Imperial Vienna',     'Karntner Ring 16, Vienna',                   310.00, 5, 1, 'Former palace of the Duke of Wurttemberg, now a Viennese imperial institution.',  'available',  41),
-- Vilnius (city_id=42)
(83, 'Stikliai Hotel',            'Gaono 7, Vilnius',                            90.00, 5, 1, 'Intimate five-star hotel in the heart of the UNESCO Baroque old town.',           'available',  42),
(84, 'Shakespeare Boutique Hotel','Bernardinu 8-8, Vilnius',                    70.00, 4, 1, 'Romantic literary-themed hotel in a restored 17th-century building.',             'available',  42),
-- Warsaw (city_id=43)
(85, 'Hotel Bristol Warsaw',      'Krakowskie Przedmiescie 42-44, Warsaw',      160.00, 5, 1, 'Grand neoclassical-Art Nouveau hotel on the Royal Road since 1901.',              'available',  43),
(86, 'Raffles Europejski Warsaw', 'Krakowskie Przedmiescie 13, Warsaw',         200.00, 5, 1, 'Opulent 19th-century landmark hotel recently restored to its original splendour.', 'available',  43),
-- Zagreb (city_id=44)
(87, 'Esplanade Zagreb Hotel',    'Mihanoviceva 1, Zagreb',                     130.00, 5, 1, 'Art Deco grand hotel built in 1925 for passengers of the Orient Express.',        'available',  44),
(88, 'Hotel Jagerhorn',           'Ilica 14, Zagreb',                            75.00, 3, 1, 'Oldest hotel in Zagreb, tucked into a courtyard just off Ban Jelacic Square.',    'available',  44);
