	rollout roll_liste_contours_typo "Contours typologie" width:375 height:262
	(
				
				local	m_plug
				local	m_typo
				
				local liste_typo 		=#()
				local liste_ids_typo 	=#()
				local liste_quartier 	=#()
				
				fn shape_filt 		obj = superclassof obj == shape  and findItem liste_typo	obj == 0
				
				
		multiListBox 'lbx_quartier' "Quartier" pos:[5,6] width:173 height:16 align:#left
		button 'btn_ajouter' ">" pos:[179,25] width:16 height:16 align:#left
				
		button 'btn_retirer' "<" pos:[179,40] width:16 height:16 align:#left
		multiListBox 'lbx_typo' "Typologie" pos:[196,6] width:173 height:16 align:#left
		button 'btn_annuler' "Annuler" pos:[309,238] width:60 height:20 align:#left
		button 'btn_valider' "Valider" pos:[250,238] width:60 height:20 align:#left
				
		button 'btn_selec_tout' "Tout" pos:[63,238] width:30 height:20 align:#left
		checkbutton 'ckb_pick' "Pick" pos:[34,238] width:30 height:20 toolTip:"Sélection par cadre de sélection." align:#left
				
		checkbutton 'ckb_cadreSelec' "Sel." pos:[5,238] width:30 height:20 toolTip:"Sélection par cadre de sélection." align:#left
		button 'btn_selec_aucun' "Aucun" pos:[92,238] width:33 height:20 align:#left
				
				fn redimensionner 	=(
					
					if roll_liste_contours_typo.width < 375 do   roll_liste_contours_typo.width = 375
					if roll_liste_contours_typo.height < 100 do roll_liste_contours_typo.height = 100
					
					local bords 				= 5
					local interColonnes 		= 18
					local largeur_colonne 	= ( roll_liste_contours_typo.width	-	2*bords	-	interColonnes ) / 2
					local hauteur_colonne	=	roll_liste_contours_typo.height - bords - 44
					local hauteur_btnsDuBas	=	roll_liste_contours_typo.height - 25
					
					
					
					lbx_quartier.width 	= largeur_colonne
					lbx_typo.width 		= largeur_colonne
					lbx_quartier.height 	= hauteur_colonne
					lbx_typo.height 		= hauteur_colonne
					lbx_typo.pos.x 		= bords + largeur_colonne + interColonnes
					
					btn_ajouter.pos.x		=	bords + largeur_colonne
					btn_retirer.pos.x		=	bords + largeur_colonne
					
					btn_valider.pos.y				=	hauteur_btnsDuBas
					btn_annuler.pos.y			=	hauteur_btnsDuBas
					btn_selec_tout.pos.y		=	hauteur_btnsDuBas
					btn_selec_aucun.pos.y		=	hauteur_btnsDuBas
					ckb_pick.pos.y				=	hauteur_btnsDuBas
					ckb_cadreSelec.pos.y		=	hauteur_btnsDuBas
					
					
					btn_valider.pos.x			=	roll_liste_contours_typo.width - 122 - bords
					btn_annuler.pos.x		=	btn_valider.pos.x + 61
				)
				
				
				
				
				fn actualiser =(
					format "ROLL ACTUALISER () \n "
					local noms_shapes_quartier = for obj in liste_quartier	collect  obj.name
					lbx_quartier.items = noms_shapes_quartier
					
					local noms_shapes_typo	= for obj in liste_typo	collect  obj.name
					lbx_typo.items = noms_shapes_typo
					format "liste_ids_typo : %\n" liste_ids_typo
					
				)
				fn actualiser_listes =(
					liste_quartier	=	for i = 1 to $.p_contours.count where not ( liste_ids_typo as bitarray)[i]		collect  $.p_contours[i]
					liste_typo		= 	for i = 1 to $.p_contours.count where ( liste_ids_typo as bitarray)[i]				collect $.p_contours[i]
				)
				fn initialiser_listes =(
					liste_quartier	=	for i = 1 to $.p_contours.count where ( m_typo.contours_index as bitarray)[i]			collect  $.p_contours[i]
					liste_typo		= 	for i = 1 to $.p_contours.count where ( m_typo.contours_groupe as bitarray)[i]		collect 	$.p_contours[i]
					
					format "	INITIALISER : m_typo : %\n" m_typo
					format "	INITIALISER : $.p_contours : %\n" $.p_contours
					format "	INITIALISER : m_typo.contours_index  : %\n" 	( m_typo.contours_index )
					format "	INITIALISER : m_typo.contours_groupe  : %\n" 	( m_typo.contours_groupe )
					format "	INITIALISER : liste_quartier : %\n" liste_quartier
					format "	INITIALISER : liste_typo : %\n" liste_typo
					
					liste_ids_typo = for i = 1 to $.p_contours.count where findItem liste_typo 	$.p_contours[i] != 0 collect i
					format "INITIALISER : liste_ids_typo : %\n" liste_ids_typo
				)
				
				
				
				
				
				
		on roll_liste_contours_typo open do
		(
			redimensionner ()
		-- 			initialiser_listes ()
		-- 			actualiser ()
		)
		on roll_liste_contours_typo resized size do
		(
				redimensionner ()
			)
		on btn_ajouter pressed do
		(
			
			local ids_aAjouter	=	 lbx_quartier.selection as array
			
			-- on les ajoute au typo -------
			for id_quartier in ids_aAjouter do
				append	liste_typo	liste_quartier[ id_quartier ]
			
			
			liste_ids_typo = for i = 1 to $.p_contours.count where findItem liste_typo $.p_contours[i] != 0 collect i
			
			
			--- on les retire de la quartier ----------
			for i = ids_aAjouter.count to 1 by -1 do 
				deleteItem	liste_quartier		ids_aAjouter[i]
			
			actualiser ()
		)
		on btn_retirer pressed do
		(
			
			local ids_aRetirer	=	 lbx_typo.selection as array
			
			-- on les ajoute au quartier -------
			for id_quartier in ids_aRetirer do
				append	liste_quartier	liste_typo[ id_quartier ]
			
			-- on les retire du typo -------
			for i = ids_aRetirer.count to 1 by -1 do
				deleteItem	liste_typo	ids_aRetirer[ i ]
			
			liste_ids_typo = for i = 1 to $.p_contours.count where findItem liste_typo $.p_contours[i] != 0 collect i
				
		-- 					liste_quartier		=	for obj in shapes where findItem	liste_typo 	obj	== 0 and obj.isHidden	== true	or chk_hidden.checked			collect  obj
			
			actualiser ()
		)
		on btn_annuler pressed do
			destroydialog roll_liste_contours_typo
		on btn_valider pressed do
		(
		-- 			m_plug.p_contours = #()
		-- 			m_plug.core.ajouter_contours 	liste_typo
			
			m_typo.contours_groupe = liste_ids_typo
			m_plug.core.analyser_typologies ()
			m_plug.core.enregistrer_typologies ()
			
			m_plug.actualiser_rollouts ()
			destroydialog roll_liste_contours_typo	
		)
		on btn_selec_tout pressed do
		(
				liste_typo				+=	liste_quartier
				liste_quartier			= 	#()
				
				liste_ids_typo = for i = 1 to $.p_contours.count where findItem liste_typo $.p_contours[i] != 0 collect i
				
				actualiser ()
			)
		on ckb_pick changed state do
		(
			
				if  state do (
					local shps_aAjouter = pickObject filter:shape_filt  count:#multiple  forceListenerFocus:false	rubberBand:$.position 	rubberBandColor:yellow 
					if shps_aAjouter.count > 0 do (
						
						-- on les ajoute au typo -------
						for shp in shps_aAjouter do
							appendIfUnique	liste_typo		shp
						
						liste_ids_typo = for i = 1 to $.p_contours.count where findItem liste_typo $.p_contours[i] != 0 collect i
						
						actualiser_listes ()
						
		-- 								--- on les retire de la quartier ----------
		-- 								for i = ids_aAjouter.count to 1 by -1 do 
		-- 									deleteItem	liste_quartier		ids_aAjouter[i]
						
						actualiser ()
					)
					ckb_pick.checked = false
				)
			)
		on ckb_cadreSelec changed state do
		(
		
			)
	)
	