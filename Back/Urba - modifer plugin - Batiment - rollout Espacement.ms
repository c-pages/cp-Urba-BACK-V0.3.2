
	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeur_longueurFixe "urba_editeurFacadesEspacement" width:234 height:85
	(
		
		include "$userScripts\cp - GLOBAL\UI.ms"
		include "$userScripts\cp - GLOBAL\DragDialog.ms"
		
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		local m_cible			---- le plug cilbé
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ctro des imgtags ---
		local m_titre
		
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
										
		spinner 'spn_longueur_composant' "" pos:[116,33] width:111 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left

		
		
		label 'lbl140' "Longueur:" pos:[10,33] width:55 height:13 align:#left
 
		
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
			
			format "initialiser - roll_urba_editeur_longueurFixe\n"
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeur_longueurFixe		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de façades"
			m_titre.setCouleur (color 255 255 255 )
-- 			m_titre.setCouleurFond ( color 200 200 200 )

			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeur_longueurFixe.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			actualiser()

		)
		
		
		------------  Evenements	----------------------------------------------------------------------------------

				
				
				
		
			--m_prt.fermer ()

		on roll_urba_editeur_longueurFixe lbuttondown _pos 	do
			m_drag.demarrer ()
		on roll_urba_editeur_longueurFixe lbuttonup _pos 	do
			m_drag.arreter ()
		on roll_urba_editeur_longueurFixe mouseMove _pos 	do
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
			destroydialog roll_urba_editeur_longueurFixe
		on spn_longueur_composant changed val do
		(
					m_prt.set_longueur_composant			val		m_cible
					actualiser ()
				)
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	