
---- PRERENDU	-----------
callbacks.removescripts 	id:	#urbaBat_preRenderProxy
global batiments_asProxy =#()
txt ="with redraw off (\n"
txt +="	for bat in objects where classof bat == Urba_Batiment do (\n"
txt +="		if 	bat.affiche_asProxy  do (\n"
txt +="			bat.affiche_asProxy = false\n"
txt +="			bat.core.actualiser ()\n"
txt +="			append	batiments_asProxy		bat\n"
txt +="	)	\n	)	\n )	\n	"
callbacks.addscript 	#preRender 	txt 		id:#urbaBat_preRenderProxy



---- post rendu	-----------
callbacks.removescripts 	id:#urbaBat_postRenderProxy
txt_post +="	for bat in batiments_asProxy do (\n"
txt_post +="			bat.affiche_asProxy = true\n"
txt_post +="			bat.core.actualiser ()\n"
txt_post +="		)\n"
callbacks.addscript 	#postRender 	txt_post 		id:#urbaBat_postRenderProxy



