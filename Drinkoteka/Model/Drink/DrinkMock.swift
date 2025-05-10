import SwiftData

func sklMock() -> Skl_M {
	let skladnik1 = Skl_M(sklID: "woda", sklNazwa: "Woda", sklKat: .inne, sklProc: 0, sklKolor: "bezbarwny", sklFoto: "", sklStan: .jest, sklOpis: "Najpowszechniejszy rozpuszczalnik na świecie", sklKal: 0, sklMiara: .ml, sklWWW: "www.woda.com")
	return skladnik1
}

func sklMockArray() -> [Skl_M] {
	let skladnik1 = Skl_M(sklID: "woda", sklNazwa: "Woda", sklKat: .inne, sklProc: 0, sklKolor: "bezbarwny", sklFoto: "", sklStan: .jest, sklOpis: "Najpowszechniejszy rozpuszczalnik na świecie", sklKal: 0, sklMiara: .ml, sklWWW: "www.woda.com")
	let skladnik2 = Skl_M(sklID: "tequila", sklNazwa: "Tequila", sklKat: .alkohol, sklProc: 50, sklKolor: "bezbarwny", sklFoto: "", sklStan: .brak, sklOpis: "Meksykańska wóda", sklKal: 0, sklMiara: .ml, sklWWW: "www.tequila.com")
	let skladnik3 = Skl_M(sklID: "cukier", sklNazwa: "Cukier", sklKat: .inne, sklProc: 0, sklKolor: "bialy", sklFoto: "", sklStan: .jest, sklOpis: "Po prostu cukier", sklKal: 0, sklMiara: .gr, sklWWW: "www.cukier.com")
	return [skladnik1, skladnik2, skladnik3]
}

func drMockArray() -> [Dr_M] {
	let arr = [drMock(), drMock()]
	return arr
}

func drMock() -> Dr_M {

	let drink = Dr_M(
		id: "testowy",
		drinkID: "testowy",
		drNazwa: "Testowy",
		drKat: .koktail,
		drZrodlo: "IBA Niezapomniane",
		drKolor: "Fioletowy",
		drFoto: "",
		drProc: 22,
		drSlodycz: .slodki,
		drSzklo: .koktailowy,
		drUlubiony: false,
		drNotatka: "Notatka do drinka",
		drUwagi: "Uwagi do drinka",
		drWWW: "www.example.com",
		drKal: 500,
		drMoc: .sredni,
		drBrakuje: 3,
		drAlkGlowny: [.brandy],
		drSklad: [],
		drPrzepis: [],
		drPolecany: true
	)

	let drink2 = Dr_M(
		id: "testowy2",
		drinkID: "testowy2",
		drNazwa: "Testowy2",
		drKat: .koktail,
		drZrodlo: "IBA Inne",
		drKolor: "Turkusowy",
		drFoto: "",
		drProc: 30,
		drSlodycz: .slodki,
		drSzklo: .koktailowy,
		drUlubiony: false,
		drNotatka: "Notatka do drinka 2",
		drUwagi: "Uwagi do drinka 2",
		drWWW: "www.example2.com",
		drKal: 300,
		drMoc: .sredni,
		drBrakuje: 3,
		drAlkGlowny: [.brandy],
		drSklad: [],
		drPrzepis: [],
		drPolecany: true
	)

	let skladnik1 = Skl_M(sklID: "woda", sklNazwa: "Woda", sklKat: .inne, sklProc: 0, sklKolor: "bezbarwny", sklFoto: "", sklStan: .jest, sklOpis: "Najpowszechniejszy rozpuszczalnik na świecie", sklKal: 0, sklMiara: .ml, sklWWW: "www.woda.com")
	let skladnik2 = Skl_M(sklID: "tequila", sklNazwa: "Tequila", sklKat: .alkohol, sklProc: 50, sklKolor: "bezbarwny", sklFoto: "", sklStan: .jest, sklOpis: "Meksykańska wóda", sklKal: 0, sklMiara: .ml, sklWWW: "www.tequila.com")
	let skladnik3 = Skl_M(sklID: "cukier", sklNazwa: "Cukier", sklKat: .inne, sklProc: 0, sklKolor: "bialy", sklFoto: "", sklStan: .jest, sklOpis: "Po prostu cukier", sklKal: 0, sklMiara: .gr, sklWWW: "www.cukier.com")


	let przepis1 = DrPrzepis_M(relacjaDrink: drink, drinkID: "testowy", przepNo: 1, przepOpis: "Do shakera wsyp kostki lodu.", przepOpcja: false)
	let przepis2 = DrPrzepis_M(relacjaDrink: drink, drinkID: "testowy", przepNo: 2, przepOpis: "Wlej wszystkie składniki.",	przepOpcja: false)
	let przepis3 = DrPrzepis_M(relacjaDrink: drink, drinkID: "testowy", przepNo: 3, przepOpis: "Wstrząśnij.", przepOpcja: false)
	let przepis4 = DrPrzepis_M(relacjaDrink: drink, drinkID: "testowy", przepNo: 4, przepOpis: "Przelej do schłodzonego kieliszka do koktajli.", przepOpcja: false)
	let przepis5 = DrPrzepis_M(relacjaDrink: drink, drinkID: "testowy", przepNo: 5, przepOpis: "Posyp świeżo zmielonym gałką muszkatołową.", przepOpcja: false)
	let drPrzepisyMock: [DrPrzepis_M] = [przepis1, przepis2, przepis3, przepis4, przepis5]



	let drskl1 = DrSkladnik_M(relacjaDrink: drink, skladnik: skladnik1, sklNo: 1, sklIlosc: 30, sklMiara: .ml, sklInfo: "", sklOpcja: false)
	let drskl2 = DrSkladnik_M(relacjaDrink: drink, skladnik: skladnik2, sklNo: 2, sklIlosc: 30, sklMiara: .ml, sklInfo: "", sklOpcja: false)
	let drskl3 = DrSkladnik_M(relacjaDrink: drink, skladnik: skladnik3, sklNo: 3, sklIlosc: 30, sklMiara: .ml, sklInfo: "", sklOpcja: false)

	let drSkladnikiMock = [drskl1, drskl2, drskl3]

	drink.drPrzepis = drPrzepisyMock
	drink.drSklad = drSkladnikiMock
	return drink
}
