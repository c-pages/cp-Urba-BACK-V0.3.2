
	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeurFacadesEspacement "urba_editeurFacadesEspacement" width:234 height:85
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ctro des imgtags ---
		local m_titre
		
		local m_cible		-- le plus cilbé
--- images bouton fermer ---
		local murs_types 	= #("Gouttereaux + Pignons", "Gouttereaux", "Pignons")
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
										openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
										openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
										)
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
										
		edittext 'edt_nom_composant' "" pos:[6,26] width:220 height:16 align:#left
		spinner 'spn_longueur_composant' "" pos:[79,43] width:148 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left

		checkbox 'chk_longueur_compo' "longueur:" pos:[9,44] width:62 height:14 align:#left
		
		
		
		button 'btn_valider' "Valider" pos:[8,59] width:110 height:16 align:#left
				
				
		button 'btn_annuler' "Annuler" pos:[117,59] width:110 height:16 align:#left
	
		
				
		
		------------  Fonctions	----------------------------------------------------------------------------------
		---- Gere l'état du bouton  -----
		fn etatBtnFermer		_etat =(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		
		
		fn actualiser = (
			
		)
		
		---- Initialisation de la fenetre  -----
		fn initialiser = (
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
			m_titre.setCouleur (color 255 255 255 )
-- 			m_titre.setCouleurFond ( color 200 200 200 )

			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			actualiser()

		)
		
		
		------------  Evenements	----------------------------------------------------------------------------------

				
				
				
		
		on roll_urba_editeurFacadesEspacement lbuttondown _pos 	do
			m_drag.demarrer ()
		on roll_urba_editeurFacadesEspacement lbuttonup _pos 	do
			m_drag.arreter ()
		on roll_urba_editeurFacadesEspacement mouseMove _pos 	do
			m_drag.suivreSouris ()
		on ui_btnFermer mouseover do
			etatBtnFermer #Survol
		on ui_btnFermer mouseout do
			etatBtnFermer #Repos
		on ui_btnFermer mouseDown do
			etatBtnFermer #Press
		on ui_btnFermer mouseUp do
			etatBtnFermer #Repos
		on ui_btnFermer click do
			m_prt.fermer ()
		on edt_nom_composant entered txt do
		(
					m_prt.set_nom_composants	txt		m_cible
					actualiser ()
				)
		on spn_longueur_composant changed val do
		(
					m_prt.set_longueur_composant			val		m_cible
					actualiser ()
				)
	)
	
	createdialog roll_urba_editeurFacadesEspacement
	
	
			

	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeurFacades_modeles "urba_editeurFacadesModeles" width:236 height:226
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ctro des imgtags ---
		local m_titre
		
		local m_cible		-- le plus cilbé
		
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
											openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Pressé ----
										)
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left

		
		
		edittext 'edt_nom_composant' "" pos:[6,26] width:220 height:16 align:#left
		listbox 'lbx_modeles' "" pos:[9,59] width:214 height:9 align:#left
		button 'btn_ajouter_modele' "+" pos:[193,44] width:16 height:16 align:#left
		button 'btn_supprimer_modele' "-" pos:[208,44] width:16 height:16 align:#left
		label 'lbl12' "Modèles:" pos:[10,44] width:53 height:15 align:#left
		
		
		
		spinner 'spn_proba_modele' "" pos:[79,182] width:148 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
		label 'lbl_proba_modele' "Probabilité:" pos:[10,182] width:58 height:15 align:#left
										
										
		button 'btn_valider' "Valider" pos:[8,200] width:110 height:16 align:#left
				
				
		button 'btn_annuler' "Annuler" pos:[117,200] width:110 height:16 align:#left
	
		
		------------  Fonctions	----------------------------------------------------------------------------------
		---- Gere l'état du bouton  -----
		fn etatBtnFermer		_etat =(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		
		
		fn actualiser = (
			
			
		)
		
		---- Initialisation de la fenetre  -----
		fn initialiser = (
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
			m_titre.setCouleur (color 255 255 255 )
-- 			m_titre.setCouleurFond ( color 200 200 200 )

			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			actualiser()

		)
		
		
		------------  Evenements	----------------------------------------------------------------------------------
	
				
		
		
		
		
		
		
		on roll_urba_editeurFacades_modeles lbuttondown _pos 	do
			m_drag.demarrer ()
		on roll_urba_editeurFacades_modeles lbuttonup _pos 	do
			m_drag.arreter ()
		on roll_urba_editeurFacades_modeles mouseMove _pos 	do
			m_drag.suivreSouris ()
		on ui_btnFermer mouseover do
			etatBtnFermer #Survol
		on ui_btnFermer mouseout do
			etatBtnFermer #Repos
		on ui_btnFermer mouseDown do
			etatBtnFermer #Press
		on ui_btnFermer mouseUp do
			etatBtnFermer #Repos
		on ui_btnFermer click do
			m_prt.fermer ()
		on edt_nom_composant entered txt do
		(
					m_prt.set_nom_composants	txt		m_cible
					actualiser ()
				)
		on lbx_modeles selected val do
			m_prt.afficher_modele		val 	m_cible
		on btn_ajouter_modele pressed do
		(
					m_prt.ajouter_modele				state		m_cible
					actualiser ()
				)
		on btn_supprimer_modele pressed do
		(
					m_prt.supprimer_modele				state		m_cible
					actualiser ()
				)
		on spn_proba_modele changed val do
		(
					m_prt.set_proba_modele			val		m_cible
					actualiser ()
				)
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
