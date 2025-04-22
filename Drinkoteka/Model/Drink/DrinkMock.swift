import SwiftData

struct DrinkMock {
	static func mockContainer() -> (Dr_M, ModelContainer) {
		let container = try! ModelContainer(
			for: Dr_M.self, DrSkladnik_M.self, DrPrzepis_M.self,
			configurations: ModelConfiguration(isStoredInMemoryOnly: true)
		)
		let context = container.mainContext

		let drinio = Dr_M(
			id: "alexander",
			drinkID: "alexander",
			drNazwa: "Alexander",
			drKat: .koktail,
			drZrodlo: "IBA Niezapomniane",
			drKolor: "Fioletowy",
			drFoto: "",
			drProc: 22,
			drSlodycz: .slodki,
			drSzklo: .koktailowy,
			drUlubiony: false,
			drNotatka: "",
			drUwagi: "",
			drWWW: "",
			drKal: 0,
			drMoc: .sredni,
			drBrakuje: 0,
			drAlkGlowny: [.brandy]
		)

		let skladniki: [DrSkladnik_M] = [
			DrSkladnik_M(id: UUID().uuidString,
							 relacjaDrink: drinio,
							 drinkID: "alexander",
							 skladnikID: "koniak",
							 sklNo: 1,
							 sklIlosc: 30,
							 sklMiara: .ml,
							 sklInfo: "",
							 sklOpcja: false),
			DrSkladnik_M(id: UUID().uuidString,
							 relacjaDrink: drinio,
							 drinkID: "alexander",
							 skladnikID: "likierkakaowy",
							 sklNo: 2,
							 sklIlosc: 30,
							 sklMiara: .ml,
							 sklInfo: "",
							 sklOpcja: false),
			DrSkladnik_M(id: UUID().uuidString,
							 relacjaDrink: drinio,
							 drinkID: "alexander",
							 skladnikID: "smietana",
							 sklNo: 3,
							 sklIlosc: 30,
							 sklMiara: .ml,
							 sklInfo: "",
							 sklOpcja: false)
		]

		let przepisy: [DrPrzepis_M] = [
			DrPrzepis_M(id: UUID().uuidString,
							relacjaDrink: drinio,
							drinkID: "alexander",
							przepNo: 1,
							przepOpis: "Do shakera wsyp kostki lodu.",
							przepOpcja: false),
			DrPrzepis_M(id: UUID().uuidString,
							relacjaDrink: drinio,
							drinkID: "alexander",
							przepNo: 2,
							przepOpis: "Wlej wszystkie składniki.",
							przepOpcja: false),
			DrPrzepis_M(id: UUID().uuidString,
							relacjaDrink: drinio,
							drinkID: "alexander",
							przepNo: 3,
							przepOpis: "Wstrząśnij.",
							przepOpcja: false),
			DrPrzepis_M(id: UUID().uuidString,
							relacjaDrink: drinio,
							drinkID: "alexander",
							przepNo: 4,
							przepOpis: "Przelej do schłodzonego kieliszka do koktajli.",
							przepOpcja: false),
			DrPrzepis_M(id: UUID().uuidString,
							relacjaDrink: drinio,
							drinkID: "alexander",
							przepNo: 5,
							przepOpis: "Posyp świeżo zmielonym gałką muszkatołową.",
							przepOpcja: false)
		]

		context.insert(drinio)
		skladniki.forEach { context.insert($0) }
		przepisy.forEach { context.insert($0) }

		return (drinio, container)
	}
}
