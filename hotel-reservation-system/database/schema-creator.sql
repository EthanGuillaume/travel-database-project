-- schema-creator.sql
-- Run this once to set up your local SQLite database.
-- Usage (from the backend/ directory):
--   python db.py
-- Or directly via sqlite3:
--   sqlite3 travel.db < database/schema-creator.sql

DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS guest_user;
DROP TABLE IF EXISTS registered_user;
DROP TABLE IF EXISTS hotel;
DROP TABLE IF EXISTS city;
DROP TABLE IF EXISTS users;

-- ─── Create tables ───────────────────────────────────────────────────────────
CREATE TABLE users (
    user_id   INTEGER PRIMARY KEY,
    username  TEXT NOT NULL,
    user_type TEXT NOT NULL,
    CHECK (user_type IN ('registered', 'guest'))
);

CREATE TABLE city (
    city_id              INTEGER PRIMARY KEY,
    city_name            TEXT NOT NULL,
    country              TEXT,
    region               TEXT,
    description          TEXT,
    avg_hotel_price_low  REAL,
    avg_hotel_price_high REAL,
    CHECK (avg_hotel_price_low >= 0),
    CHECK (avg_hotel_price_high >= avg_hotel_price_low)
);

CREATE TABLE hotel (
    hotel_id            INTEGER PRIMARY KEY,
    hotel_name          TEXT NOT NULL,
    address             TEXT,
    price_per_night     REAL,
    star_rating         INTEGER,
    restaurant_included INTEGER,
    description         TEXT,
    availability_status TEXT,
    city_id             INTEGER,
    FOREIGN KEY (city_id) REFERENCES city(city_id),
    CHECK (price_per_night >= 0),
    CHECK (star_rating BETWEEN 1 AND 5),
    CHECK (restaurant_included IN (0, 1)),
    CHECK (availability_status IN ('available', 'unavailable'))
);

CREATE TABLE registered_user (
    user_id              INTEGER PRIMARY KEY,
    email                TEXT NOT NULL UNIQUE,
    password_hash        TEXT NOT NULL,
    preferred_budget_min REAL,
    preferred_budget_max REAL,
    availability_start   TEXT,
    availability_end     TEXT,
    preferred_city_id    INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (preferred_city_id) REFERENCES city(city_id),
    CHECK (preferred_budget_min >= 0),
    CHECK (preferred_budget_max >= preferred_budget_min),
    CHECK (availability_end >= availability_start)
);

CREATE TABLE guest_user (
    user_id          INTEGER PRIMARY KEY,
    browse_only_flag INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (browse_only_flag IN (0, 1))
);

CREATE TABLE reservation (
    reservation_id     INTEGER PRIMARY KEY,
    check_in_date      TEXT NOT NULL,
    check_out_date     TEXT NOT NULL,
    number_of_guests   INTEGER,
    total_cost         REAL,
    reservation_status TEXT,
    user_id            INTEGER,
    hotel_id           INTEGER,
    FOREIGN KEY (user_id) REFERENCES registered_user(user_id),
    FOREIGN KEY (hotel_id) REFERENCES hotel(hotel_id),
    CHECK (number_of_guests > 0),
    CHECK (total_cost >= 0),
    CHECK (reservation_status IN ('pending', 'confirmed', 'cancelled')),
    CHECK (check_out_date > check_in_date)
);

-- ─── Cities: all European capitals ──────────────────────────────────────────
-- city_id, city_name, country, region, description, avg_hotel_price_low, avg_hotel_price_high

INSERT INTO city VALUES (1,  'Tirana',           'Albania',                'Southeastern Europe', 'Vibrant capital nestled between mountains, blending Ottoman heritage with modern energy.',            40.00,  100.00);
INSERT INTO city VALUES (2,  'Andorra la Vella', 'Andorra',                'Southern Europe',     'High-altitude Pyrenean capital known for duty-free shopping and ski resorts.',                       70.00,  180.00);
INSERT INTO city VALUES (3,  'Vienna',            'Austria',                'Western Europe',      'Imperial capital renowned for classical music, coffee houses, and grand baroque architecture.',      90.00,  250.00);
INSERT INTO city VALUES (4,  'Minsk',             'Belarus',                'Eastern Europe',      'Soviet-era capital featuring grand boulevards, extensive green parks, and neoclassical buildings.',  35.00,   90.00);
INSERT INTO city VALUES (5,  'Brussels',          'Belgium',                'Western Europe',      'Political heart of the EU, famous for its Grand Place, waffles, chocolate, and art nouveau.',       80.00,  220.00);
INSERT INTO city VALUES (6,  'Sarajevo',          'Bosnia and Herzegovina', 'Southeastern Europe', 'East-meets-West city known for its Ottoman bazaar, Austro-Hungarian quarter, and resilience.',      40.00,  100.00);
INSERT INTO city VALUES (7,  'Sofia',             'Bulgaria',               'Eastern Europe',      'Ancient capital at the foot of Vitosha Mountain mixing Roman ruins with communist monuments.',       40.00,  120.00);
INSERT INTO city VALUES (8,  'Zagreb',            'Croatia',                'Southeastern Europe', 'Central European capital with a medieval upper town, vibrant cafe culture, and great museums.',     50.00,  140.00);
INSERT INTO city VALUES (9,  'Nicosia',           'Cyprus',                 'Southern Europe',     'World''s last divided capital, straddling the Green Line between Greek and Turkish communities.',    60.00,  160.00);
INSERT INTO city VALUES (10, 'Prague',            'Czech Republic',         'Eastern Europe',      'Fairy-tale city of a hundred spires with a perfectly preserved medieval old town on the Vltava.',   60.00,  180.00);
INSERT INTO city VALUES (11, 'Copenhagen',        'Denmark',                'Northern Europe',     'Design-forward Nordic capital known for Nyhavn, New Nordic cuisine, and cycling culture.',          100.00,  300.00);
INSERT INTO city VALUES (12, 'Tallinn',           'Estonia',                'Northern Europe',     'Best-preserved medieval old town in Northern Europe, blending Hanseatic charm with digital innovation.',50.00, 150.00);
INSERT INTO city VALUES (13, 'Helsinki',          'Finland',                'Northern Europe',     'Elegant Baltic capital known for design, saunas, pristine nature, and archipelago scenery.',        90.00,  250.00);
INSERT INTO city VALUES (14, 'Paris',             'France',                 'Western Europe',      'City of Light and love, home to the Eiffel Tower, Louvre, haute cuisine, and haute couture.',      150.00,  400.00);
INSERT INTO city VALUES (15, 'Berlin',            'Germany',                'Western Europe',      'Reunified capital pulsing with history, cutting-edge art, nightlife, and multicultural energy.',     80.00,  250.00);
INSERT INTO city VALUES (16, 'Athens',            'Greece',                 'Southern Europe',     'Cradle of Western civilization dominated by the Acropolis, with a vibrant modern city below.',       60.00,  180.00);
INSERT INTO city VALUES (17, 'Budapest',          'Hungary',                'Eastern Europe',      'Pearl of the Danube split into Buda and Pest, famous for thermal baths and stunning parliament.',    50.00,  150.00);
INSERT INTO city VALUES (18, 'Reykjavik',         'Iceland',                'Northern Europe',     'World''s northernmost capital, gateway to the Northern Lights, geysers, and volcanic landscapes.',  100.00,  300.00);
INSERT INTO city VALUES (19, 'Dublin',            'Ireland',                'Western Europe',      'Literary capital famous for its Georgian architecture, pub culture, and warm Irish hospitality.',   100.00,  280.00);
INSERT INTO city VALUES (20, 'Rome',              'Italy',                  'Southern Europe',     'Eternal City layering ancient ruins, Renaissance art, baroque fountains, and incredible food.',     100.00,  300.00);
INSERT INTO city VALUES (21, 'Pristina',          'Kosovo',                 'Southeastern Europe', 'Young and energetic capital of Europe''s newest country with a lively cafe and nightlife scene.',   35.00,   90.00);
INSERT INTO city VALUES (22, 'Riga',              'Latvia',                 'Northern Europe',     'Art nouveau capital of the Baltics with a UNESCO-listed historic center and vibrant nightlife.',     50.00,  140.00);
INSERT INTO city VALUES (23, 'Vaduz',             'Liechtenstein',          'Western Europe',      'Tiny Rhine Valley capital dominated by its medieval castle perched on a forested hillside.',        100.00,  250.00);
INSERT INTO city VALUES (24, 'Vilnius',           'Lithuania',              'Northern Europe',     'Baroque gem with the largest old town in Eastern Europe and a thriving arts and startup scene.',     50.00,  140.00);
INSERT INTO city VALUES (25, 'Luxembourg City',  'Luxembourg',             'Western Europe',      'Grand Duchy capital perched on cliffs above river gorges with a UNESCO-listed old quarter.',        100.00,  280.00);
INSERT INTO city VALUES (26, 'Valletta',          'Malta',                  'Southern Europe',     'World''s smallest EU capital, packed with baroque architecture, fortifications, and warm sunshine.', 80.00,  220.00);
INSERT INTO city VALUES (27, 'Chisinau',          'Moldova',                'Eastern Europe',      'Leafy post-Soviet capital known for wide boulevards, wine culture, and Soviet-era architecture.',    30.00,   80.00);
INSERT INTO city VALUES (28, 'Monaco',            'Monaco',                 'Southern Europe',     'Glamorous microstate on the French Riviera synonymous with casinos, Formula 1, and superyachts.',   200.00,  600.00);
INSERT INTO city VALUES (29, 'Podgorica',         'Montenegro',             'Southeastern Europe', 'Modern capital at the confluence of two rivers, near spectacular Skadar Lake and coastal resorts.',  40.00,  100.00);
INSERT INTO city VALUES (30, 'Amsterdam',         'Netherlands',            'Western Europe',      'Canal-ringed capital renowned for its museums, cycling culture, liberal spirit, and tulip fields.',  100.00,  280.00);
INSERT INTO city VALUES (31, 'Skopje',            'North Macedonia',        'Southeastern Europe', 'Capital rebuilt after a 1963 earthquake, now filled with neoclassical statues and Ottoman bazaars.', 35.00,   90.00);
INSERT INTO city VALUES (32, 'Oslo',              'Norway',                 'Northern Europe',     'Prosperous fjord capital offering world-class museums, vibrant food scene, and outdoor adventure.',  120.00,  350.00);
INSERT INTO city VALUES (33, 'Warsaw',            'Poland',                 'Eastern Europe',      'Resilient capital completely rebuilt after WWII, now a dynamic business and cultural hub.',          50.00,  130.00);
INSERT INTO city VALUES (34, 'Lisbon',            'Portugal',               'Southern Europe',     'Hilly Atlantic capital of pastel facades, vintage trams, fado music, and fresh seafood.',            70.00,  200.00);
INSERT INTO city VALUES (35, 'Bucharest',         'Romania',                'Eastern Europe',      'Little Paris of the East with belle epoque architecture, palace of parliament, and buzzing nightlife.', 40.00, 110.00);
INSERT INTO city VALUES (36, 'Moscow',            'Russia',                 'Eastern Europe',      'Vast capital of Russia defined by the Kremlin, Red Square, and grand Soviet-era monuments.',         60.00,  200.00);
INSERT INTO city VALUES (37, 'Belgrade',          'Serbia',                 'Southeastern Europe', 'Fortress city at the confluence of the Sava and Danube, known for hospitality and nightlife.',       40.00,  110.00);
INSERT INTO city VALUES (38, 'Bratislava',        'Slovakia',               'Eastern Europe',      'Compact Danube capital with a hilltop castle, charming old town, and proximity to Vienna.',          50.00,  140.00);
INSERT INTO city VALUES (39, 'Ljubljana',         'Slovenia',               'Southeastern Europe', 'Green and walkable capital straddling the Ljubljanica river beneath a medieval hilltop castle.',     60.00,  160.00);
INSERT INTO city VALUES (40, 'Madrid',            'Spain',                  'Southern Europe',     'Sunny Castilian capital of world-class art museums, tapas bars, passionate football, and flamenco.',  80.00,  220.00);
INSERT INTO city VALUES (41, 'Stockholm',         'Sweden',                 'Northern Europe',     'Scandinavian capital spread across 14 islands where Lake Malaren meets the Baltic Sea.',            100.00,  280.00);
INSERT INTO city VALUES (42, 'Bern',              'Switzerland',            'Western Europe',      'Medieval federal capital with arcaded sandstone streets, a famous clock tower, and bear park.',      120.00,  350.00);
INSERT INTO city VALUES (43, 'Kyiv',              'Ukraine',                'Eastern Europe',      'Ancient Slavic capital on the Dnieper river, home to golden-domed monasteries and vibrant culture.',  40.00,  110.00);
INSERT INTO city VALUES (44, 'London',            'United Kingdom',         'Western Europe',      'Global metropolis blending royal pageantry, world-leading museums, multicultural food, and finance.',120.00,  350.00);

-- ─── Hotels: 2 per capital city ──────────────────────────────────────────────
-- hotel_id, hotel_name, address, price_per_night, star_rating, restaurant_included, description, availability_status, city_id

-- Tirana (city_id=1)
INSERT INTO hotel VALUES (1,  'Tirana International Hotel', 'Skanderbeg Square, Tirana',            80.00,  4, 1, 'Modern hotel at the heart of Tirana with great views of Skanderbeg Square.',                  'available',   1);
INSERT INTO hotel VALUES (2,  'Hotel Rogner Tirana',        'Blvd. Deshmoret e Kombit, Tirana',     60.00,  3, 0, 'Comfortable hotel with garden and outdoor pool in central Tirana.',                         'available',   1);

-- Andorra la Vella (city_id=2)
INSERT INTO hotel VALUES (3,  'Hotel Plaza Andorra',        'Placa de la Rotonda, Andorra la Vella', 130.00, 4, 1, 'Elegant hotel in the Pyrenees offering stunning mountain views and ski access.',            'available',   2);
INSERT INTO hotel VALUES (4,  'Hotel Andorra Park',         'Carrer les Canals, Andorra la Vella',   110.00, 4, 1, 'Charming mountain hotel with spa, wellness facilities, and panoramic Pyrenean scenery.',   'available',   2);

-- Vienna (city_id=3)
INSERT INTO hotel VALUES (5,  'Hotel Bristol Vienna',       'Kaerntner Ring 1, Vienna',              280.00, 5, 1, 'Legendary five-star hotel on the Ringstrasse with classic Viennese elegance since 1892.',  'available',   3);
INSERT INTO hotel VALUES (6,  'Hotel Sacher Wien',          'Philharmoniker Strasse 4, Vienna',      320.00, 5, 1, 'Iconic luxury hotel famous for its Original Sacher-Torte and imperial decor.',             'available',   3);

-- Minsk (city_id=4)
INSERT INTO hotel VALUES (7,  'Hotel Europe Minsk',         'Internatsionalnaya 23, Minsk',          70.00,  4, 1, 'First-class hotel in central Minsk with modern amenities and conference facilities.',        'available',   4);
INSERT INTO hotel VALUES (8,  'Crowne Plaza Minsk',         'Kirov Street 13, Minsk',                85.00,  4, 1, 'Contemporary hotel near the city center offering comfortable rooms and quality dining.',    'available',   4);

-- Brussels (city_id=5)
INSERT INTO hotel VALUES (9,  'Hotel Amigo Brussels',       'Rue de l Amigo 1, Brussels',            250.00, 5, 1, 'Five-star luxury hotel steps from the Grand Place with refined Belgian art decor.',        'available',   5);
INSERT INTO hotel VALUES (10, 'Hotel Metropole Brussels',   'Place de Brouckere 31, Brussels',       190.00, 4, 1, 'Historic belle epoque hotel in the heart of Brussels city center since 1895.',            'available',   5);

-- Sarajevo (city_id=6)
INSERT INTO hotel VALUES (11, 'Hotel Europe Sarajevo',      'Julije Benesica 1, Sarajevo',           90.00,  4, 1, 'Historic hotel in the old town blending Ottoman and Austro-Hungarian architecture.',       'available',   6);
INSERT INTO hotel VALUES (12, 'Holiday Inn Sarajevo',       'Zmaja od Bosne 4, Sarajevo',            75.00,  3, 1, 'Well-located hotel near the old town with comfortable rooms and full services.',          'available',   6);

-- Sofia (city_id=7)
INSERT INTO hotel VALUES (13, 'Hotel Grand Sofia',          'Gurko Street 1, Sofia',                 85.00,  4, 1, 'Elegant hotel in central Sofia near the National Palace of Culture with rooftop bar.',    'available',   7);
INSERT INTO hotel VALUES (14, 'Sense Hotel Sofia',          'Karnigradska Street 28, Sofia',         70.00,  4, 1, 'Boutique hotel with a rooftop terrace offering panoramic views over Sofia.',              'available',   7);

-- Zagreb (city_id=8)
INSERT INTO hotel VALUES (15, 'Hotel Esplanade Zagreb',     'Mihanoviceva 1, Zagreb',               150.00,  5, 1, 'Historic art deco hotel built for Orient Express passengers in 1925.',                    'available',   8);
INSERT INTO hotel VALUES (16, 'Hotel Palace Zagreb',        'Strossmayerov trg 10, Zagreb',         110.00,  4, 1, 'Elegant hotel in a beautiful 19th-century building in central Zagreb.',                  'available',   8);

-- Nicosia (city_id=9)
INSERT INTO hotel VALUES (17, 'Hilton Nicosia',             'Archbishop Makarios Ave 98, Nicosia',  120.00,  5, 1, 'Full-service luxury hotel in the heart of the Cypriot capital with outdoor pool.',        'available',   9);
INSERT INTO hotel VALUES (18, 'Hotel Classic Nicosia',      'Rigenis Street 94, Nicosia',            80.00,  3, 0, 'Comfortable three-star hotel offering simple yet charming accommodation in Nicosia.',    'available',   9);

-- Prague (city_id=10)
INSERT INTO hotel VALUES (19, 'Four Seasons Prague',        'Veleslavinova 2a, Prague',             300.00,  5, 1, 'Luxury waterfront hotel with stunning views of Prague Castle and Charles Bridge.',        'available',  10);
INSERT INTO hotel VALUES (20, 'Mandarin Oriental Prague',   'Nebovidska 459/1, Prague',             260.00,  5, 1, 'Exquisite luxury hotel in a beautifully renovated 14th-century monastery.',               'available',  10);

-- Copenhagen (city_id=11)
INSERT INTO hotel VALUES (21, 'Hotel d Angleterre Copenhagen', 'Kongens Nytorv 34, Copenhagen',    350.00,  5, 1, 'Iconic grand hotel overlooking Kongens Nytorv in the center of Copenhagen since 1755.',   'available',  11);
INSERT INTO hotel VALUES (22, 'Hotel Nimb Copenhagen',      'Bernstorffsgade 5, Copenhagen',        290.00,  5, 1, 'Boutique luxury hotel inside the Tivoli Gardens with Moorish-inspired architecture.',    'available',  11);

-- Tallinn (city_id=12)
INSERT INTO hotel VALUES (23, 'Hotel Telegraaf Tallinn',    'Vene 9, Tallinn',                      120.00,  5, 1, 'Refined five-star hotel in a restored 19th-century telegraph building in Old Town.',      'available',  12);
INSERT INTO hotel VALUES (24, 'Hotel Viru Tallinn',         'Viru Valjak 4, Tallinn',                90.00,  4, 1, 'Historic landmark hotel transformed into a modern comfortable stay in central Tallinn.',  'available',  12);

-- Helsinki (city_id=13)
INSERT INTO hotel VALUES (25, 'Hotel Kamp Helsinki',        'Pohjoisesplanadi 29, Helsinki',        270.00,  5, 1, 'Grand historic hotel on the Esplanade at the heart of Helsinki since 1887.',               'available',  13);
INSERT INTO hotel VALUES (26, 'Hotel Haven Helsinki',       'Unioninkatu 17, Helsinki',             220.00,  5, 1, 'Boutique luxury hotel overlooking Market Square and the South Harbour.',                 'available',  13);

-- Paris (city_id=14)
INSERT INTO hotel VALUES (27, 'Hotel Ritz Paris',           'Place Vendome 15, Paris',              900.00,  5, 1, 'Legendary palace hotel on Place Vendome synonymous with Parisian luxury since 1898.',    'available',  14);
INSERT INTO hotel VALUES (28, 'Hotel Le Meurice Paris',     'Rue de Rivoli 228, Paris',             750.00,  5, 1, 'Palace hotel overlooking the Tuileries Garden with world-class dining since 1835.',      'available',  14);

-- Berlin (city_id=15)
INSERT INTO hotel VALUES (29, 'Hotel Adlon Kempinski Berlin', 'Unter den Linden 77, Berlin',        350.00,  5, 1, 'Legendary luxury hotel at the Brandenburg Gate, a symbol of Berlin since 1907.',           'available',  15);
INSERT INTO hotel VALUES (30, 'Hotel de Rome Berlin',       'Behrenstrasse 37, Berlin',             280.00,  5, 1, 'Lavish boutique hotel in a splendidly restored 19th-century Dresdner Bank building.',     'available',  15);

-- Athens (city_id=16)
INSERT INTO hotel VALUES (31, 'Hotel Grande Bretagne Athens', 'Syntagma Square, Athens',            300.00,  5, 1, 'Iconic hotel overlooking Syntagma Square with rooftop views of the Acropolis since 1874.','available',  16);
INSERT INTO hotel VALUES (32, 'Electra Palace Athens',      'Navarchou Nikodimou 18, Athens',       190.00,  5, 1, 'Luxury hotel in the Plaka district with rooftop pool and spectacular Acropolis views.',   'available',  16);

-- Budapest (city_id=17)
INSERT INTO hotel VALUES (33, 'Four Seasons Gresham Palace', 'Szechenyi Istvan ter 5, Budapest',    380.00,  5, 1, 'Art nouveau masterpiece on the bank of the Danube with stunning castle views.',           'available',  17);
INSERT INTO hotel VALUES (34, 'New York Palace Budapest',   'Erzsebet krt 9-11, Budapest',          240.00,  5, 1, 'Opulent historic hotel home to the world-famous New York Cafe since 1894.',               'available',  17);

-- Reykjavik (city_id=18)
INSERT INTO hotel VALUES (35, 'Hotel Borg Reykjavik',       'Posthusstraeti 11, Reykjavik',         220.00,  4, 1, 'Art deco landmark hotel overlooking Austurvollur Square in central Reykjavik since 1930.','available',  18);
INSERT INTO hotel VALUES (36, 'Canopy by Hilton Reykjavik', 'Smidjustigur 4, Reykjavik',            190.00,  4, 1, 'Stylish design hotel in the heart of 101 Reykjavik near the main shopping street.',      'available',  18);

-- Dublin (city_id=19)
INSERT INTO hotel VALUES (37, 'The Shelbourne Dublin',      'St Stephens Green 27, Dublin',         280.00,  5, 1, 'Iconic Victorian hotel overlooking St Stephens Green in the heart of Dublin since 1824.', 'available',  19);
INSERT INTO hotel VALUES (38, 'Hotel Merrion Dublin',       'Merrion Street Upper, Dublin',         330.00,  5, 1, 'Award-winning hotel in four Georgian townhouses with an impressive Irish art collection.',  'available',  19);

-- Rome (city_id=20)
INSERT INTO hotel VALUES (39, 'Hotel Eden Rome',            'Via Ludovisi 49, Rome',                500.00,  5, 1, 'Legendary luxury hotel atop the Via Veneto hill with a panoramic rooftop terrace.',       'available',  20);
INSERT INTO hotel VALUES (40, 'Hotel de Russie Rome',       'Via del Babuino 9, Rome',              450.00,  5, 1, 'Renowned retreat near Piazza del Popolo with a lush secret garden courtyard.',            'available',  20);

-- Pristina (city_id=21)
INSERT INTO hotel VALUES (41, 'Swiss Diamond Pristina',     'Rr Garibaldi 2, Pristina',              85.00,  4, 1, 'Upscale hotel in central Pristina with modern rooms, spa, and conference center.',         'available',  21);
INSERT INTO hotel VALUES (42, 'Hotel Grand Pristina',       'Blvd Bill Clinton, Pristina',           65.00,  3, 1, 'Centrally located hotel offering comfortable rooms and a popular local restaurant.',      'available',  21);

-- Riga (city_id=22)
INSERT INTO hotel VALUES (43, 'Hotel Riga',                 'Aspazijas bulvaris 22, Riga',          100.00,  4, 1, 'Historic hotel in the heart of Riga steps from the Art Nouveau district.',               'available',  22);
INSERT INTO hotel VALUES (44, 'Dome Hotel Riga',            'Miesnieku iela 4, Riga',               130.00,  5, 1, 'Boutique luxury hotel inside a beautifully restored 18th-century building near the Dome Cathedral.', 'available', 22);

-- Vaduz (city_id=23)
INSERT INTO hotel VALUES (45, 'Hotel Real Vaduz',           'Stadtle 21, Vaduz',                    160.00,  4, 1, 'Classic hotel in the center of Vaduz with fine dining and sweeping Rhine Valley views.',   'available',  23);
INSERT INTO hotel VALUES (46, 'Gasthof Loewen Vaduz',       'Herrengasse 35, Vaduz',                120.00,  3, 1, 'Traditional guest house in the historic center of Vaduz with Alpine charm.',              'available',  23);

-- Vilnius (city_id=24)
INSERT INTO hotel VALUES (47, 'Hotel Stikliai Vilnius',     'Gaono g. 7, Vilnius',                  140.00,  5, 1, 'Elegant boutique hotel in the heart of Vilnius UNESCO Old Town.',                        'available',  24);
INSERT INTO hotel VALUES (48, 'Kempinski Hotel Cathedral Square', 'Universiteto g. 14, Vilnius',    160.00,  5, 1, 'Grand hotel overlooking the Cathedral with impeccable service and a rooftop bar.',        'available',  24);

-- Luxembourg City (city_id=25)
INSERT INTO hotel VALUES (49, 'Hotel Le Royal Luxembourg',  'Blvd Royal 12, Luxembourg City',       220.00,  5, 1, 'Prestigious five-star hotel in the banking district with spa, pool, and fine dining.',    'available',  25);
INSERT INTO hotel VALUES (50, 'Sofitel Luxembourg Le Grand Ducal', 'Rue du Fort Niedergrunewald 1, Luxembourg City', 180.00, 5, 1, 'Contemporary luxury hotel in Kirchberg near EU institutions.', 'available', 25);

-- Valletta (city_id=26)
INSERT INTO hotel VALUES (51, 'Hotel Phoenicia Malta',      'The Mall Floriana, Valletta',          220.00,  5, 1, 'Grand colonial hotel just outside Valletta gate with beautiful Mediterranean gardens.',   'available',  26);
INSERT INTO hotel VALUES (52, 'The Palace Malta',           'High Street Sliema, Valletta',         170.00,  4, 1, 'Boutique luxury hotel with rooftop pool and stunning views over the Grand Harbour.',     'available',  26);

-- Chisinau (city_id=27)
INSERT INTO hotel VALUES (53, 'Hotel Jolly Alon Chisinau',  'Maria Cibotari St 37, Chisinau',        55.00,  4, 1, 'Modern hotel in central Chisinau with comfortable rooms and a popular restaurant.',       'available',  27);
INSERT INTO hotel VALUES (54, 'Nobil Luxury Boutique Hotel', '31 August 1989 St 18, Chisinau',       65.00,  4, 1, 'Boutique hotel in the heart of the city with elegant decor and personalized service.',    'available',  27);

-- Monaco (city_id=28)
INSERT INTO hotel VALUES (55, 'Hotel de Paris Monte-Carlo', 'Place du Casino, Monaco',              900.00,  5, 1, 'Legendary grand hotel overlooking the Casino de Monte-Carlo since 1864.',                 'available',  28);
INSERT INTO hotel VALUES (56, 'Hotel Hermitage Monte-Carlo', 'Square Beaumarchais, Monaco',         700.00,  5, 1, 'Belle epoque palace with a stunning glass-domed winter garden and sea views.',           'available',  28);

-- Podgorica (city_id=29)
INSERT INTO hotel VALUES (57, 'Hilton Podgorica Crna Gora', 'Moskovska Street 2, Podgorica',         95.00,  4, 1, 'Contemporary upscale hotel in the city center with a rooftop pool and modern amenities.','available',  29);
INSERT INTO hotel VALUES (58, 'Hotel Hemera Podgorica',     'Slobode Street 22, Podgorica',          70.00,  3, 1, 'Comfortable mid-range hotel conveniently located in the center of Podgorica.',          'available',  29);

-- Amsterdam (city_id=30)
INSERT INTO hotel VALUES (59, 'Waldorf Astoria Amsterdam', 'Herengracht 542, Amsterdam',            550.00,  5, 1, 'Ultra-luxury hotel in six 17th-century canal houses on the prestigious Golden Bend.',    'available',  30);
INSERT INTO hotel VALUES (60, 'The Dylan Amsterdam',       'Keizersgracht 384, Amsterdam',           380.00,  5, 1, 'Exclusive boutique hotel in a restored 17th-century former theatre on the canal.',       'available',  30);

-- Skopje (city_id=31)
INSERT INTO hotel VALUES (61, 'Hotel Arka Skopje',          'Partizanski Odredi Blvd 59, Skopje',    70.00,  4, 1, 'Contemporary hotel near the city center with a rooftop restaurant overlooking Skopje.',  'available',  31);
INSERT INTO hotel VALUES (62, 'Hotel Stone Bridge Skopje',  'Kej Dimitar Vlahov 1, Skopje',          60.00,  3, 1, 'Hotel located beside the famous Byzantine Stone Bridge over the Vardar River.',          'available',  31);

-- Oslo (city_id=32)
INSERT INTO hotel VALUES (63, 'Hotel Continental Oslo',     'Stortingsgata 24, Oslo',               310.00,  5, 1, 'Sophisticated hotel directly across from the National Theatre since 1900.',               'available',  32);
INSERT INTO hotel VALUES (64, 'Grand Hotel Oslo',           'Karl Johans Gate 31, Oslo',             280.00,  5, 1, 'Landmark historic hotel on the main boulevard, traditional venue for Nobel Peace Prize laureates.', 'available', 32);

-- Warsaw (city_id=33)
INSERT INTO hotel VALUES (65, 'Hotel Bristol Warsaw',       'Krakowskie Przedmiescie 42, Warsaw',   200.00,  5, 1, 'Legendary five-star hotel in a stunning neo-renaissance building in central Warsaw since 1901.', 'available', 33);
INSERT INTO hotel VALUES (66, 'Raffles Europejski Warsaw',  'Krakowskie Przedmiescie 13, Warsaw',   180.00,  5, 1, 'Historic grand hotel restored to its former 19th-century Belle Epoque glory.',             'available',  33);

-- Lisbon (city_id=34)
INSERT INTO hotel VALUES (67, 'Bairro Alto Hotel Lisbon',   'Praca Luis de Camoes 2, Lisbon',        320.00,  5, 1, 'Design boutique hotel with rooftop views over the historic Bairro Alto neighborhood.',   'available',  34);
INSERT INTO hotel VALUES (68, 'Avenida Palace Lisbon',      'Rua 1 de Dezembro 123, Lisbon',         220.00,  5, 1, 'Historic Belle Epoque hotel steps from Rossio Square in central Lisbon since 1892.',     'available',  34);

-- Bucharest (city_id=35)
INSERT INTO hotel VALUES (69, 'InterContinental Bucharest', 'Bulevardul Nicolae Balcescu 4, Bucharest', 130.00, 5, 1, 'Iconic skyscraper hotel dominating University Square in the heart of Bucharest.',     'available',  35);
INSERT INTO hotel VALUES (70, 'Athenee Palace Hilton Bucharest', 'Str Episcopiei 1, Bucharest',      160.00,  5, 1, 'Historic grand hotel adjacent to the Romanian Athenaeum concert hall since 1914.',       'available',  35);

-- Moscow (city_id=36)
INSERT INTO hotel VALUES (71, 'Hotel Metropol Moscow',      'Teatralny Proezd 2, Moscow',            280.00,  5, 1, 'Opulent art nouveau hotel near the Bolshoi Theatre dating from 1907.',                   'available',  36);
INSERT INTO hotel VALUES (72, 'Four Seasons Moscow',        'Okhotny Ryad 2, Moscow',                350.00,  5, 1, 'Grandly restored hotel overlooking the Kremlin walls and Manezh Square.',                'available',  36);

-- Belgrade (city_id=37)
INSERT INTO hotel VALUES (73, 'Square Nine Hotel Belgrade', 'Studentski Trg 9, Belgrade',           150.00,  5, 1, 'Boutique luxury hotel overlooking a charming cobblestone square in the old town.',       'available',  37);
INSERT INTO hotel VALUES (74, 'Hotel Moskva Belgrade',      'Balkanska Street 1, Belgrade',         100.00,  4, 1, 'Historic landmark hotel at the corner of Terazije, a symbol of Belgrade since 1908.',    'available',  37);

-- Bratislava (city_id=38)
INSERT INTO hotel VALUES (75, 'Sheraton Bratislava Hotel',  'Pribinova 12, Bratislava',             130.00,  4, 1, 'Modern full-service hotel in the new city district with views over the Danube.',          'available',  38);
INSERT INTO hotel VALUES (76, 'Hotel Devin Bratislava',     'Riecna 4, Bratislava',                 100.00,  4, 1, 'Riverside hotel steps from the old town with castle views and Danube riverside terrace.','available',  38);

-- Ljubljana (city_id=39)
INSERT INTO hotel VALUES (77, 'Grand Hotel Union Ljubljana', 'Miklosiceva cesta 1, Ljubljana',       160.00,  5, 1, 'Art nouveau grand hotel at the heart of Ljubljana since 1905, a national landmark.',     'available',  39);
INSERT INTO hotel VALUES (78, 'Hotel Cubo Ljubljana',       'Slovenska cesta 15, Ljubljana',        130.00,  4, 1, 'Contemporary boutique design hotel in central Ljubljana with modern Slovenian style.',  'available',  39);

-- Madrid (city_id=40)
INSERT INTO hotel VALUES (79, 'Hotel Ritz Madrid',          'Plaza de la Lealtad 5, Madrid',        500.00,  5, 1, 'Palatial grand hotel commissioned by King Alfonso XIII, steps from the Prado since 1910.','available',  40);
INSERT INTO hotel VALUES (80, 'Hotel Palace Madrid',        'Plaza de las Cortes 7, Madrid',        350.00,  5, 1, 'Magnificent Belle Epoque hotel steps from the Prado Museum and Congress since 1912.',   'available',  40);

-- Stockholm (city_id=41)
INSERT INTO hotel VALUES (81, 'Grand Hotel Stockholm',      'Sodra Blasieholmshamnen 8, Stockholm', 380.00,  5, 1, 'Sweden''s most prestigious hotel, overlooking the Royal Palace since 1874.',             'available',  41);
INSERT INTO hotel VALUES (82, 'Berns Hotel Stockholm',      'Berzelii Park, Stockholm',             240.00,  4, 1, 'Historic cultural hotel in a 19th-century building with a celebrated concert hall.',     'available',  41);

-- Bern (city_id=42)
INSERT INTO hotel VALUES (83, 'Schweizerhof Bern',          'Bahnhofplatz 11, Bern',                280.00,  5, 1, 'Grand hotel opposite the main station with classic Swiss elegance and since 1859.',       'available',  42);
INSERT INTO hotel VALUES (84, 'Bellevue Palace Bern',       'Kochergasse 3, Bern',                  320.00,  5, 1, 'The Swiss government official guesthouse overlooking the dramatic Aare river gorge.',    'available',  42);

-- Kyiv (city_id=43)
INSERT INTO hotel VALUES (85, 'InterContinental Kyiv',      'Velyka Zhytomyrska 2a, Kyiv',           150.00,  5, 1, 'Luxury hotel steps from St. Michael''s Monastery with panoramic views over Kyiv.',       'available',  43);
INSERT INTO hotel VALUES (86, 'Fairmont Grand Hotel Kyiv',  'Yaroslaviv Val Street 5, Kyiv',         130.00,  5, 1, 'Elegant hotel in central Kyiv combining classic architecture with contemporary luxury.',  'available',  43);

-- London (city_id=44)
INSERT INTO hotel VALUES (87, 'The Ritz London',            '150 Piccadilly, London',               750.00,  5, 1, 'World-famous luxury hotel on Piccadilly synonymous with glamour and afternoon tea since 1906.', 'available', 44);
INSERT INTO hotel VALUES (88, 'Claridge''s London',         'Brook Street, Mayfair, London',         650.00,  5, 1, 'Art deco icon in Mayfair beloved by royalty and celebrities, open since 1812.',          'available',  44);
