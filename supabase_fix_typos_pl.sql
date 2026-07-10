-- Poprawki literówek w bazowej (PL) treści
-- Uruchom w Supabase SQL Editor.

update ingredients set description = 'Brązowy cukier uzyskany z trzciny cukrowej.' where id = 'cukiertrzcinowy';
update ingredients set description = 'Meksykański alkohol produkowany z agawy, o dymnym smaku.' where id = 'meskal';
update ingredients set description = 'Meksykański alkohol wytwarzany z agawy, o charakterystycznym, ziemistym smaku, używany w koktajlach takich jak Margarita.' where id = 'tequila';
update drinks set name = 'Dark ''n'' Stormy' where id = 'darknstormy';
update drinks set name = 'Johnny Bravo' where id = 'johnybravo';
update drinks set name = 'Mark Twain Cocktail' where id = 'marktwaincoctail';
update drink_ingredients set info = '(Shiraz lub Malbec)' where drink_id = 'newyorksour' and ingredient_id = 'winoczerwone';
update drink_ingredients set info = 'żółtka' where drink_id = 'portoflip' and ingredient_id = 'jajko';
update drink_steps set description = 'Do szklanki do whiskey wsyp kostki lodu.' where drink_id = 'americano' and step_no = 1;
update drink_steps set description = 'Wsyp lód do szklanki highball.' where drink_id = 'horsesneck' and step_no = 1;
update drink_steps set description = 'Wymieszaj pozostałe składniki z lodem w szklanicy barmańskiej.' where drink_id = 'sazerac' and step_no = 3;
update drink_steps set description = 'Napełnij szklankę tumbler lodem' where drink_id = 'vento' and step_no = 4;
update drink_steps set description = 'Przecedź do szklanki.' where drink_id = 'vento' and step_no = 5;
update drink_steps set description = 'Wsyp lód do szklanicy barmańskiej.' where drink_id = 'vieuxcarre' and step_no = 1;
update drink_steps set description = 'Na wierzchu dodaj świeżej śmietany i delikatnie zamieszaj.' where drink_id = 'whiterussian' and step_no = 4;
update drink_steps set description = 'Udekoruj plasterkiem pomarańczy i wisienką koktailową.' where drink_id = 'castaway' and step_no = 5;
update drink_steps set description = 'Udekoruj połówką plastra pomarańczy.' where drink_id = 'renegat' and step_no = 5;
update drink_steps set description = 'Wlej zawartość szklanicy.' where drink_id = 'lemoniadacytrynowa' and step_no = 4;
update drink_steps set description = 'Wlej zawartość szklanicy.' where drink_id = 'lemoniadazmieta' and step_no = 4;
update drink_steps set description = 'Wlej zawartość szklanicy. oraz zmiksowane truskawki.' where drink_id = 'lemoniadatruskawkowa' and step_no = 5;
update drink_steps set description = 'Wlej zawartość szklanicy do karafki.' where drink_id = 'lemoniadaarbuzowa' and step_no = 5;
update drink_steps set description = 'Wlej zawartość szklanicy. oraz dosyp resztę malin.' where drink_id = 'lemoniadamalinowa' and step_no = 4;
