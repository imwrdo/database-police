--tworzenie widoku
CREATE VIEW PrzestepstwaView AS
SELECT
    ID,
    Rodzaj,
    Data_przestepstwa,
    Status_przestepstwa
FROM Przestepstwa;
GO

/*
Dla celow statystycznych potrzebna jest informacja o rodzajach przestepstw (ilosci poszczegolnych), 
ktore odbyly sie w grudniu 2022 roku
*/
SELECT Rodzaj, COUNT(*) AS IloscPrzestepstw
FROM PrzestepstwaView
WHERE YEAR(Data_przestepstwa) = 2023
   AND MONTH(Data_przestepstwa) = 12
GROUP BY Rodzaj;


/*
Zostalo wprowadzone nowe prawo, ktore skraca czas wiezienia dla wszystkich przestepcow,
musimy znalezc wszystkich przestepcow, ktore sa karane za przestepstwo “narkotyki” z kodeksu karnego. 
*/
SELECT O.*
FROM Osoba O
WHERE O.PESEL IN (
    SELECT UP.PESEL_Osoby
    FROM Udzial_przestepcy_w_przestepstwie UP
    JOIN Przestepstwa P ON UP.ID_Przestepstwa = P.ID
    WHERE P.Rodzaj = 'Narkotyki'
)
ORDER BY (
    SELECT P.ID
    FROM Udzial_przestepcy_w_przestepstwie UP
    JOIN Przestepstwa P ON UP.ID_Przestepstwa = P.ID
    WHERE UP.PESEL_Osoby = O.PESEL AND P.Rodzaj = 'Narkotyki'
) DESC;


/*
Zeby wyplacic policjantom premie proporcjonalnie zatrzymaniem przeprowadzonych przez nich i 
zrozumiec kto jest najlepszym pracownikiem za ostatni czas,
trzeba uporzadkowac wszystkich policjantow wedlug ilosci (i ewentualnie rodzaju) zatrzyman za ostanie 3 miesiace
*/

SELECT TOP 5
P.Numer_legitymacji, COUNT(Z.ID) AS IloscZatrzyman, MAX(Z.Data_zatrzymania) AS OstatnieZatrzymanie
FROM Policjanci P
JOIN Udzial_policji UP ON P.Numer_legitymacji = UP.ID_Policjanta
JOIN Zatrzymania Z ON UP.ID = Z.ID
WHERE Z.Data_zatrzymania >= DATEADD(MONTH, -3, GETDATE()) -- Zatrzymania z ostatnich 3 miesiecy
GROUP BY P.Numer_legitymacji
ORDER BY IloscZatrzyman DESC, OstatnieZatrzymanie DESC;

/*
Przestepca, ktory zostal zatrzymany 22.02.2023 za *cos tam* anonimowo napisal, 
ze policjant zlamal prawo podczas jego aresztowania, 
trzeba znalezc wszystkich policjantow ktore zatrzymywali kogos w tym dniu, zeby przesluchac 
*/
SELECT P.Numer_legitymacji
FROM Policjanci P
JOIN Udzial_policji UP ON P.Numer_legitymacji = UP.ID_Policjanta
JOIN Zatrzymania Z ON UP.ID = Z.ID
WHERE Z.Data_zatrzymania = '2023-07-25';

/*
Zostal przedstawiony nowy dowod, oskarzajacy osobe X.
Wyswietlic informacje o wczesniejszych przestepstwach osoby X (gdy byly) oraz
dane o potencjalnym udziale w przestepstwie
*/

SELECT
    O.*,
    P.Rodzaj AS RodzajPrzestepstwa,
    P.Data_przestepstwa,
    PP.Przebycie_podczas_przestepstwa,
    PP.Dzialalnosc_podczas_przestepstwa
FROM
    Osoba O
LEFT JOIN Potencjalny_udzial_w_przestepstwie PP ON O.PESEL = PP.PESEL_Osoby
LEFT JOIN Przestepstwa P ON PP.ID_Przestepstwa = P.ID
WHERE O.PESEL = '96090123456';


/*
Zostalo wprowadzone nowe prawo, ktore skraca czas wiezienia dla wszystkich przestepcow,
przez to wszystkie przestepstwa zwiazane z narkotykami beda nanowo rozpatrywane.
Znajdz wszystkich swiadkow, ktorzy zeznali w sprawie o narkotykach.
*/
SELECT Udzial_Swiadkow.*, Osoba.*
FROM Udzial_Swiadkow
JOIN Osoba ON Udzial_Swiadkow.PESEL_Osoby = Osoba.PESEL
JOIN Przestepstwa ON Udzial_Swiadkow.ID_Przestepstwa = Przestepstwa.ID
WHERE Przestepstwa.Rodzaj = 'Narkotyki';

/*
Departament policji otrzymal informacje z anonimowego zrodla, ze dwoch bylych przestepcow popelnilo niedawno nowe przestepstwo. 
Nie podano konkretnych nazwisk, ale powiedziano, ze jeden z nich mial tatuaz przypominajacy gwiazde, a drugi mial piercing
Musisz pozwoli znalezc wszystkich przestepcow posiadajacych tatuaz z gwiazda lub przeklucia 
na prawych uchu oraz uzyskac informacje o przestepstwach, w ktorych brali udzial. 
*/
SELECT DISTINCT O.*, P.*
FROM Osoba O
JOIN Udzial_przestepcy_w_przestepstwie UPWP ON O.PESEL = UPWP.PESEL_Osoby
JOIN Przestepstwa P ON UPWP.ID_Przestepstwa = P.ID
WHERE O.PESEL IN (
    SELECT PESEL_Osoby
    FROM Udzial_przestepcy_w_przestepstwie
    WHERE Tatuaze LIKE '%gwiazda%'
) OR O.PESEL IN (
    SELECT PESEL_Osoby
    FROM Udzial_przestepcy_w_przestepstwie
    WHERE Przeklucia LIKE '%prawe ucho%'
);



/*
 Zgodnie z nowymi przepisami dotyczacymi broni, polski Sad Najwyzszy wymaga od 
 policji podawania pelnych informacji o przestepcach i popelnionych przestepstwach,
 w ktore zaangazowana byla bron za ostatni rok. Musisz znalezc pelna informacje o takich osobach oraz przestepstwach, 
 zarejestrowanych w roku 2023. Potrzebujemy szczegolow dotyczacych osob zaangazowanych w przestepstwo,
 danych zatrzyman oraz dowodow, w szczegolnosci tych zwiazanych z bronia.
*/
SELECT  Osoba.*, Udzial_przestepcy_w_przestepstwie.*, Zatrzymania.*, Dowody.*
FROM Udzial_przestepcy_w_przestepstwie
JOIN Osoba ON Udzial_przestepcy_w_przestepstwie.PESEL_Osoby = Osoba.PESEL
JOIN Zatrzymania_Przestepstwa ON Udzial_przestepcy_w_przestepstwie.ID_Przestepstwa = Zatrzymania_Przestepstwa.ID_Przestepstwa
JOIN Zatrzymania ON Zatrzymania_Przestepstwa.ID_zatrzymania = Zatrzymania.ID
JOIN Przestepstwa_Dowody ON Udzial_przestepcy_w_przestepstwie.ID_Przestepstwa = Przestepstwa_Dowody.ID_przestepstwa
JOIN Dowody ON Przestepstwa_Dowody.ID_dowodu = Dowody.ID
WHERE (YEAR(Zatrzymania.Data_zatrzymania) = 2023  AND Dowody.Bron IS NOT NULL);

/*
Wedlug anonimowych informacji popelniono morderstwo, a na miejscu zbrodni pozostawiono slady krwi sprawcy,
ktorego dokonal jeden z bylych sprawcow mieszkajacy obecnie w Warszawie. 
Zapisz wszystkie informacje o przestepcach i ich zbrodniach, 
ktorzy obecnie mieszkaja w Warszawie i ktorych dane DNA sa dostepne w bazie danych
*/
SELECT Osoba.*, Przestepstwa.Rodzaj, Przestepstwa.Data_przestepstwa, Przestepstwa.Adres, Przestepstwa.Opis
FROM Osoba
JOIN Udzial_przestepcy_w_przestepstwie ON Osoba.PESEL = Udzial_przestepcy_w_przestepstwie.PESEL_Osoby
JOIN Przestepstwa ON Udzial_przestepcy_w_przestepstwie.ID_Przestepstwa = Przestepstwa.ID
JOIN Dowody ON Przestepstwa.ID = Dowody.ID
WHERE Udzial_przestepcy_w_przestepstwie.Aktualny_pobyt LIKE 'Warszawa%' AND Dowody.Probki_DNA = 'Jest';
/*
Weszlo w zycie nowe prawo, zgodnie z ktorym wszyscy przestepcy, 
ktorzy popelnili przestepstwo wiecej niz jeden raz,
musza zostac ukarani z uwzglednieniem okolicznosci obciazajacych. 
Znajdz wszystkich przestepcow, ktorzy popelnili przestepstwo wiecej niz raz i wpisz ich dane osobowe.
*/
SELECT
    Udzial_przestepcy_w_przestepstwie.PESEL_Osoby,
    Osoba.Imie,
    Osoba.Nazwisko,
    Osoba.Data_urodzenia,
    COUNT(Zatrzymania_Przestepstwa.ID_zatrzymania) AS Liczba_Zatrzyman
FROM Udzial_przestepcy_w_przestepstwie
JOIN Osoba ON Udzial_przestepcy_w_przestepstwie.PESEL_Osoby = Osoba.PESEL
JOIN Zatrzymania_Przestepstwa ON Udzial_przestepcy_w_przestepstwie.ID_Przestepstwa = Zatrzymania_Przestepstwa.ID_Przestepstwa
GROUP BY
    Udzial_przestepcy_w_przestepstwie.PESEL_Osoby,
    Osoba.Imie,
    Osoba.Nazwisko,
    Osoba.Data_urodzenia
HAVING COUNT(Zatrzymania_Przestepstwa.ID_zatrzymania) > 1;

DROP VIEW PrzestepstwaView;









