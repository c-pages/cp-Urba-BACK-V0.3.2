	rollout roll_liste_contours "Contours" width:375 height:262
			(
				
				local	m_plug
				
				local liste_contours =#()
				local liste_scene =#()
				
				fn shape_filt 		obj = superclassof obj == shape  and findItem liste_contours	obj == 0
				
				
				multiListBox 'lbx_scene' "Scène" pos:[5,6] width:173 height:16 align:#left
				button 'btn_ajouter' ">" pos:[179,25] width:16 height:16 align:#left
				
				button 'btn_retirer' "<" pos:[179,40] width:16 height:16 align:#left
				multiListBox 'lbx_quartier' "Quartier" pos:[196,6] width:173 height:16 align:#left
				button 'btn_annuler' "Annuler" pos:[309,238] width:60 height:20 align:#left
				button 'btn_valider' "Valider" pos:[250,238] width:60 height:20 align:#left
				
				button 'btn_selec_tout' "Tout" pos:[63,238] width:30 height:20 align:#left
				checkbox 'chk_hidden' "Cachés" pos:[126,242] width:58 height:15 align:#left
				checkbutton 'ckb_pick' "Pick" pos:[34,238] width:30 height:20 toolTip:"Sélection par cadre de sélection." align:#left
				
				checkbutton 'ckb_cadreSelec' "Sel." pos:[5,238] width:30 height:20 toolTip:"Sélection par cadre de sélection." align:#left
				button 'btn_selec_aucun' "Aucun" pos:[92,238] width:33 height:20 align:#left
				
				fn redimensionner 	=(
					
					if roll_liste_contours.width < 375 do   roll_liste_contours.width = 375
					if roll_liste_contours.height < 100 do roll_liste_contours.height = 100
					
					local bords 				= 5
					local interColonnes 		= 18
					local largeur_colonne 	= ( roll_liste_contours.width	-	2*bords	-	interColonnes ) / 2
					local hauteur_colonne	=	roll_liste_contours.height - bords - 44
					local hauteur_btnsDuBas	=	roll_liste_contours.height - 25
					
					
					
					lbx_scene.width 		= largeur_colonne
					lbx_quartier.width 	= largeur_colonne
					lbx_scene.height 		= hauteur_colonne
					lbx_quartier.height 	= hauteur_colonne
					lbx_quartier.pos.x 	= bords + largeur_colonne + interColonnes
					
					btn_ajouter.pos.x		=	bords + largeur_colonne
					btn_retirer.pos.x		=	bords + largeur_colonne
					
					btn_valider.pos.y				=	hauteur_btnsDuBas
					btn_annuler.pos.y			=	hauteur_btnsDuBas
					btn_selec_tout.pos.y		=	hauteur_btnsDuBas
					btn_selec_aucun.pos.y		=	hauteur_btnsDuBas
					chk_hidden.pos.y				=	hauteur_btnsDuBas
					ckb_pick.pos.y				=	hauteur_btnsDuBas
					ckb_cadreSelec.pos.y		=	hauteur_btnsDuBas
					
					
					btn_valider.pos.x			=	roll_liste_contours.width - 122 - bords
					btn_annuler.pos.x		=	btn_valider.pos.x + 61
				)
				
				
				
				
				fn actualiser =(
					
					local noms_shapes_scene = for obj in liste_scene	collect  obj.name
					lbx_scene.items = noms_shapes_scene
					
					local noms_shapes_quartier	= for obj in liste_contours	collect  obj.name
					lbx_quartier.items = noms_shapes_quartier
					
				)
				fn actualiser_liste_scene =(
					liste_scene		=	for obj in shapes where not chk_hidden.checked	and findItem	liste_contours 	obj	== 0	and obj.isHiddenInVpt	== false	or chk_hidden.checked	 and findItem	liste_contours 	obj	== 0		collect  obj
				)
				
				
				
				
				
				
				on roll_liste_contours open do
				(
					redimensionner ()
					liste_contours	= 	for obj in $.p_contours 	collect  obj
						actualiser_liste_scene ()
					actualiser ()
				)
				on roll_liste_contours resized size do
			(
					redimensionner ()
				)
				on btn_ajouter pressed do
				(
					
					local ids_aAjouter	=	 lbx_scene.selection as array
					
					-- on les ajoute au quartier -------
					for id_scene in ids_aAjouter do
						append	liste_contours	liste_scene[ id_scene ]
					
					--- on les retire de la scene ----------
					for i = ids_aAjouter.count to 1 by -1 do 
						deleteItem	liste_scene		ids_aAjouter[i]
					
					actualiser ()
				)
				on btn_retirer pressed do
				(
					
					local ids_aRetirer	=	 lbx_quartier.selection as array
					
					-- on les retire du quartier -------
					for i = ids_aRetirer.count to 1 by -1 do
						deleteItem	liste_contours	ids_aRetirer[ i ]
					
					--- on actualise la liste de la scene ----------
					actualiser_liste_scene ()
				-- 					liste_scene		=	for obj in shapes where findItem	liste_contours 	obj	== 0 and obj.isHidden	== true	or chk_hidden.checked			collect  obj
					
					actualiser ()
				)
				on btn_annuler pressed do
					destroydialog roll_liste_contours
				on btn_valider pressed do
				(
					m_plug.p_contours = #()
					m_plug.core.ajouter_contours 	liste_contours
					
					
					m_plug.actualiser_rollouts ()
					destroydialog roll_liste_contours	
				)
				on btn_selec_tout pressed do
				(
						liste_contours		+=	liste_scene
						liste_scene			= 	#()
						
						actualiser ()
					)
				on chk_hidden changed state do
				(
						actualiser_liste_scene ()
					actualiser ()
				
					)
				on ckb_pick changed state do
				(
					
						if  state do (
							local shps_aAjouter = pickObject filter:shape_filt  count:#multiple  forceListenerFocus:false	rubberBand:$.position 	rubberBandColor:yellow 
							if shps_aAjouter.count > 0 do (
								
								-- on les ajoute au quartier -------
								for shp in shps_aAjouter do
									appendIfUnique	liste_contours		shp
								
								actualiser_liste_scene ()
								
-- 								--- on les retire de la scene ----------
-- 								for i = ids_aAjouter.count to 1 by -1 do 
-- 									deleteItem	liste_scene		ids_aAjouter[i]
								
								actualiser ()
							)
							ckb_pick.checked = false
						)
					)
				on ckb_cadreSelec changed state do
				(
				
					)
				on btn_aucun pressed do
				(
						liste_contours		+=	liste_scene
						liste_scene			= 	#()
						
						actualiser ()
					)
			)
			