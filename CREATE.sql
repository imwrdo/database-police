CREATE TABLE Osoba (
	PESEL CHAR(11) UNIQUE NOT NULL CHECK (ISNUMERIC(PESEL) = 1),
	Imie VARCHAR(30) NOT NULL CHECK (ISNUMERIC(Imie) = 0),
	Nazwisko VARCHAR(30) NOT NULL CHECK (ISNUMERIC(Nazwisko) = 0),
	Data_urodzenia DATE NOT NULL,
	Odzisk_palca VARBINARY(MAX),
	Numer_telefonu VARCHAR(11) NOT NULL CHECK (Numer_telefonu LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9]'),
	Wzrost INT CHECK (Wzrost BETWEEN 50 AND 300),
	Waga DECIMAL CHECK (Waga BETWEEN 0 AND 500),
	Plec VARCHAR(10) NOT NULL CHECK (Plec IN ('Mezczyzna', 'Kobieta', 'Inne')),
	Tatuaze VARCHAR(255) CHECK (ISNUMERIC(Tatuaze) = 0),
	Przeklucia VARCHAR(255) CHECK (ISNUMERIC(Przeklucia) = 0),
	Kolor_wlosow VARCHAR(50) CHECK (ISNUMERIC(Kolor_wlosow) = 0),
	Status_prawny VARCHAR(50) CHECK (Status_prawny IN ('Cywylny', 'Zolnierz', 'Policjant')),
	PRIMARY KEY(PESEL)
);

CREATE TABLE Policjanci(
	Numer_legitymacji CHAR(11) PRIMARY KEY NOT NULL CHECK (Numer_legitymacji LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Procesy(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Postepowanie_sadowe VARCHAR(255) CHECK (ISNUMERIC(Postepowanie_sadowe) = 0)
);

CREATE TABLE Dowody(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Dowody_przedmiotowe VARCHAR(500) CHECK (ISNUMERIC(Dowody_przedmiotowe) = 0),
	Zeznania VARCHAR(5) NOT NULL CHECK (Zeznania IN ('Jest', 'Niema')),
	Probki_DNA VARCHAR(5) NOT NULL CHECK (Probki_DNA IN ('Jest', 'Niema')),
	Bron VARCHAR(500) CHECK (ISNUMERIC(Bron) = 0)
);

CREATE TABLE Przestepstwa(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Rodzaj VARCHAR(100) NOT NULL CHECK (ISNUMERIC(Rodzaj) = 0),
	Data_przestepstwa DATE,
	Godzina TIME,
	Adres VARCHAR(255),
	Opis VARCHAR(1000) CHECK (ISNUMERIC(Opis) = 0),
	Status_przestepstwa VARCHAR(12) NOT NULL CHECK (Status_przestepstwa IN ('Wykryte', 'Nie wykryte')),
	ID_Procesu CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_Procesu) = 1),
	FOREIGN KEY (ID_Procesu) REFERENCES Procesy(ID) ON DELETE CASCADE ON UPDATE CASCADE
);
ALTER TABLE Przestepstwa ADD CONSTRAINT Adres  CHECK (ISNUMERIC(Adres) = 0);

CREATE TABLE Potencjalny_udzial_w_przestepstwie(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Przebycie_podczas_przestepstwa VARCHAR(1000) CHECK (ISNUMERIC(Przebycie_podczas_przestepstwa) = 0),
	Dzialalnosc_podczas_przestepstwa VARCHAR(1000) CHECK (ISNUMERIC(Dzialalnosc_podczas_przestepstwa) = 0),
	PESEL_Osoby CHAR(11) NOT NULL CHECK (ISNUMERIC(PESEL_Osoby) = 1),
	ID_Przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_Przestepstwa) = 1),
	FOREIGN KEY (PESEL_Osoby) REFERENCES Osoba(PESEL) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_Przestepstwa) REFERENCES Przestepstwa(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Udzial_Swiadkow(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Opis_widzianego VARCHAR(1000) NOT NULL CHECK (ISNUMERIC(Opis_widzianego) = 0),
	PESEL_Osoby CHAR(11) NOT NULL CHECK (ISNUMERIC(PESEL_Osoby) = 1),
	ID_Przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_Przestepstwa) = 1),
	FOREIGN KEY (PESEL_Osoby) REFERENCES Osoba(PESEL) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_Przestepstwa) REFERENCES Przestepstwa(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Udzial_policji(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Udzial VARCHAR(1000) CHECK (ISNUMERIC(Udzial) = 0),
	ID_Policjanta CHAR(11) NOT NULL CHECK (ID_Policjanta LIKE '[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9]'),
	FOREIGN KEY (ID_Policjanta) REFERENCES Policjanci(Numer_legitymacji) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Udzial_przestepcy_w_przestepstwie(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1) DEFAULT (1),
	Udzial VARCHAR(1000) CHECK (ISNUMERIC(Udzial) = 0),
	Aktualny_pobyt VARCHAR(255) CHECK (ISNUMERIC(Aktualny_pobyt) = 0),
	PESEL_Osoby CHAR(11) NOT NULL CHECK (ISNUMERIC(PESEL_Osoby) = 1),
	ID_Przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_Przestepstwa) = 1),
	FOREIGN KEY (PESEL_Osoby) REFERENCES Osoba(PESEL) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_Przestepstwa) REFERENCES Przestepstwa(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Udzial_ofiary(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Skutki VARCHAR(500) NOT NULL CHECK (ISNUMERIC(Skutki) = 0),
	PESEL_Osoby CHAR(11) NOT NULL CHECK (ISNUMERIC(PESEL_Osoby) = 1),
	ID_Przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_Przestepstwa) = 1),
	FOREIGN KEY (PESEL_Osoby) REFERENCES Osoba(PESEL) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (ID_Przestepstwa) REFERENCES Przestepstwa(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Zatrzymania(
	ID CHAR(11) PRIMARY KEY NOT NULL CHECK (ISNUMERIC(ID) = 1),
	Adres_zatrzymania VARCHAR(100) CHECK (ISNUMERIC(Adres_zatrzymania) = 0),
	Data_zatrzymania DATE
);

CREATE TABLE Dzial_pol_Przestepstwa(
	ID_udzial_pol CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_udzial_pol) = 1) REFERENCES Udzial_policji ON DELETE CASCADE ON UPDATE CASCADE,
	ID_przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_przestepstwa) = 1) REFERENCES Przestepstwa ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_udzial_pol, ID_przestepstwa)
);

CREATE TABLE Osoba_Zatrzymania(
	PESEL CHAR(11) NOT NULL CHECK (ISNUMERIC(PESEL) = 1) REFERENCES Osoba ON DELETE CASCADE ON UPDATE CASCADE,
	ID_zatrzymania CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_zatrzymania) = 1) REFERENCES Zatrzymania ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (PESEL, ID_zatrzymania)
);

CREATE TABLE Zatrzymania_Przestepstwa(
	ID_zatrzymania CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_zatrzymania) = 1) REFERENCES Zatrzymania ON DELETE CASCADE ON UPDATE CASCADE,
	ID_przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_przestepstwa) = 1) REFERENCES Przestepstwa ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_zatrzymania, ID_przestepstwa)
);

CREATE TABLE Przestepstwa_Dowody(
	ID_przestepstwa CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_przestepstwa) = 1) REFERENCES Przestepstwa ON DELETE CASCADE ON UPDATE CASCADE,
	ID_dowodu CHAR(11) NOT NULL CHECK (ISNUMERIC(ID_dowodu) = 1) REFERENCES Dowody ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (ID_przestepstwa, ID_dowodu)
);