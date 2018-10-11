


include  "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\recherche - simpleObject - mgr - Construction base.ms"
include "$userScripts\\cp-Urba\\docs\\recherche Bat version mesh (simpleObject)\\Menuiseries\\Menuiserie - Poignee.ms"

	
plugin simpleObject		urba_menuis_porte
name:"Porte"
classID:#(0x65251e58, 0x402a84d9)
category:"CP | Urba | menuiseries"
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuis_ouvrant"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	
	--- Optionnel:		Le plug contenant la menuiserie ("ensemble" de mensuierie) pour permettre d'enregistrer les parametres du fix dans le parent.
	local m_parent
	
	local mgr_constr	=	str_contruction_base ()
	
	
	
	parameters params_general rollout:roll_general
	(
		
		longueur 						type:#worldUnits 	ui:spn_longueur 					default:0
		hauteur 							type:#worldUnits 	ui:spn_hauteur 					default:0
		profondeur	 					type:#worldUnits 	ui:spn_profondeur				default:0
		
		menuis_epaisseur	 					type:#worldUnits 	ui:spn_cadre_ep					default:5
		vitrage_ep	 					type:#worldUnits 											default:2
		
		porte_profondeur				type:#worldUnits 	default:4.
		porte_vitree					type:#boolean 		ui:shk_porte_vitree				default:false
		porte_menuis_montants	type:#worldUnits 	ui:spn_porte_montants			default:10
		porte_menuis_travBasse	type:#worldUnits 	ui:spn_porte_travBasse			default:15
		
		poignees						type:#boolean 		ui:shk_poignees					default:true
		poignee_ht						type:#worldUnits 	ui:spn_poignee_ht				default:95.
		gonds							type:#boolean 		ui:shk_gonds						default:true
		
		ouverture_angle	 			type:#float			 	ui:spn_ouverture_angle			default:0
		ouverture_inverse			type:#boolean 		ui:shk_ouverture_inverser		default:false
		ouverture_symetrique		type:#boolean 		ui:shk_ouverture_symetrique	default:false
		
		matId_menuis					type:#integer 			ui:spn_matId_menuis			default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage			default:2
		matId_poignee					type:#integer 			ui:spn_matId_poignee			default:3
		matId_gonds					type:#integer 			ui:spn_matId_gonds				default:3
		
		montant_G						type:#boolean 		default:true
		montant_D						type:#boolean 		default:true
		traverse_H						type:#boolean 		default:true
		
	)
	rollout roll_general "Porte"	(
		
		group 	"Global" (
			spinner spn_longueur 						"longueur" 				type:#worldunits range:[0,1e20,90]
			spinner spn_hauteur 						"Hauteur" 				type:#worldunits range:[0,1e20,210]
			spinner spn_profondeur 					"Profondeur" 			type:#worldunits range:[0,1e20,20]
			spinner spn_cadre_ep	 					"Cadre" 				type:#worldunits range:[0,1e20,5]
		)
		
		group 	"Porte" (			
			checkbox	shk_porte_vitree				"Vitrée" 
			spinner spn_porte_montants	 			"Montants" 				type:#worldunits range:[0,1e20,10]	
			spinner spn_porte_travBasse 			"Trav. basse" 			type:#worldunits range:[0,1e20,10]			
		)	
		group 	"Divers" (			
			checkbox	shk_poignees					"Poignées" 
			spinner spn_poignee_ht 					"Hauteur" 				type:#worldunits range:[0,1e20,95]
			checkbox	shk_gonds						"Gonds" 
		)
		group 	"Ouverture" (
			checkbox	shk_ouverture_symetrique	"Inverser alignement" 			
			checkbox	shk_ouverture_inverser		"Inverser sens" 				
			spinner 	spn_ouverture_angle	 	"Angle" 					type:#float range:[0,180,0]
		)
		
		group 	"Material ID" (
			spinner spn_matId_menuis 				"Menuiseries" 		type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage				"Vitrage" 			type:#integer range:[1,1000,2]
			spinner spn_matId_poignee				"Poignées" 			type:#integer range:[1,1000,3]
			spinner spn_matId_gonds					"Gonds" 				type:#integer range:[1,1000,3]
		)
		
		fn actualiser = (
			spn_porte_montants.Indeterminate 	= not porte_vitree
			spn_porte_montants.enabled 				= porte_vitree
			
			spn_poignee_ht.Indeterminate 		= not poignees
			spn_poignee_ht.enabled 				= poignees
		)
		
		on roll_general					open do actualiser ()
		
		on shk_porte_vitree				changed val do		actualiser ()
		on shk_poignees					changed val do		actualiser ()
	)
	
	
	
	
	
	on buildMesh do
	(
		
		--- vider le mesh --------
		delete mesh
		
		
		--- la longueur des traverses------
		local long_trav	=	longueur
		if montant_G	do long_trav -= menuis_epaisseur
		if montant_D	do long_trav -= menuis_epaisseur
		
		--- la hauteur du vitrage -----
		local ht_vitrage	=	hauteur - menuis_epaisseur 
		if traverse_H	do ht_vitrage -= menuis_epaisseur 
		
		---- bloc porte ----
		local epaisseur_blocPorte		=	2
		local profondeur_blocPorte	=	profondeur -  porte_profondeur - .5
		local decall_blocPorte			=	if  ouverture_symetrique then porte_profondeur + .5	else 0
		
		
		
		
		
		
		------------ LE CADRE -----------------		
		--- montant G  ----------
		if montant_G do (
			--- Montant ----
			mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur			\
															prof:		profondeur			\
															ht:		hauteur				\
															matID:	matId_menuis		\
															bool:		true
			---- Blocage porte -------
			mgr_constr.ajouter_boite 	mesh		long:		epaisseur_blocPorte			\
															prof:		profondeur_blocPorte			\
															ht:		( hauteur - menuis_epaisseur )				\
															matID:	matId_menuis		\
															transf:	[menuis_epaisseur,	decall_blocPorte	,0] \
															bool:		true
		)
		--- montant D ----------	
		if montant_D do (
			--- Montant ----
			mgr_constr.ajouter_boite 	mesh		long:		menuis_epaisseur		\
															prof:		profondeur		\
															ht:		hauteur			\
															transf:	[longueur - menuis_epaisseur,0,0] 					\
															matID:	matId_menuis\
															bool:		true
			---- Blocage porte -------
			mgr_constr.ajouter_boite 	mesh		long:		epaisseur_blocPorte			\
															prof:		profondeur_blocPorte			\
															ht:		( hauteur - menuis_epaisseur )				\
															matID:	matId_menuis		\
															transf:	[longueur - menuis_epaisseur - epaisseur_blocPorte, decall_blocPorte ,0] 	\
															bool:		true
		)
		
		--- traverse haute ----------
		mgr_constr.ajouter_boite 	mesh		long:		long_trav		\
														prof:		profondeur		\
														ht:		menuis_epaisseur		 	\
														transf:	[menuis_epaisseur,0,hauteur - menuis_epaisseur]				\
														matID:	matId_menuis\
															bool:		true
		---- Blocage porte -------
		mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2* epaisseur_blocPorte )			\
														prof:		profondeur_blocPorte			\
														ht:		epaisseur_blocPorte			\
														matID:	matId_menuis		\
														transf:	[menuis_epaisseur + epaisseur_blocPorte, decall_blocPorte ,hauteur - menuis_epaisseur - epaisseur_blocPorte ] 	\
														bool:		true
		
		
		
		
		
		----- LES GONDS -----------
		local gond_rayon	=	1
		local gond_ht	=	7
		if gonds do (
			local gonds_decall_X	=	if  not ouverture_inverse		then porte_profondeur + gond_rayon	else longueur - porte_profondeur - gond_rayon
			local gonds_decall_Y	=	if  ouverture_symetrique  		then - gond_rayon	else profondeur + gond_rayon
			local gonds_decall_Z	=	hauteur / 4
			
			mgr_constr.ajouter_cylindre 	mesh		rayon:	gond_rayon		\
																ht:		gond_ht		\
																transf:	(transMatrix [ gonds_decall_X , gonds_decall_Y , hauteur / 9 ]  )	\
																matID:	matId_gonds
			
			mgr_constr.ajouter_cylindre 	mesh		rayon:	gond_rayon		\
																ht:		gond_ht		\
																transf:	(transMatrix [ gonds_decall_X , gonds_decall_Y , hauteur / 2 - gond_ht/2]  )	\
																matID:	matId_gonds
			
			mgr_constr.ajouter_cylindre 	mesh		rayon:	gond_rayon		\
																ht:		gond_ht		\
																transf:	(transMatrix [ gonds_decall_X , gonds_decall_Y , hauteur - ( hauteur / 9 ) - gond_ht  ] )	\
																matID:	matId_gonds
		)
		
		
		
		
		
		
		----- L'OUVRANT ----------------
		local ecart_cote		=	.5
		local ecart_bas 		=	1.5
		local hauteur_reel	=	hauteur - ecart_bas - ecart_cote
		
		local matrix_ouverture 			
		local matrx_origine_ouvrant 
		if not ouverture_symetrique then  (
				if not ouverture_inverse then (					
					matrx_origine_ouvrant 	=  transMatrix [0,  -porte_profondeur - gond_rayon ,ecart_bas]
					matrix_ouverture 			= rotateZMatrix	ouverture_angle * transMatrix  [menuis_epaisseur, profondeur + gond_rayon  ,0]					
				) else (
					matrx_origine_ouvrant 	= transMatrix  [-longueur + 2 * menuis_epaisseur,  - porte_profondeur - gond_rayon  ,ecart_bas]
					matrix_ouverture 			= rotateZMatrix	-ouverture_angle * transMatrix  [longueur -  menuis_epaisseur, profondeur + gond_rayon ,0]
				)
		) else (
				if not ouverture_inverse then (
					matrx_origine_ouvrant 	= 	transMatrix  [0,  0 , ecart_bas]					
					matrix_ouverture 			= rotateZMatrix	-ouverture_angle * transMatrix  [menuis_epaisseur, 0  ,0]
				) else (
					matrx_origine_ouvrant 	= transMatrix  [-longueur + 2 * menuis_epaisseur, 0  ,ecart_bas]
					matrix_ouverture 			= rotateZMatrix	ouverture_angle * transMatrix  [longueur -  menuis_epaisseur, 0  ,0]
				)
		)
		
		
		------- la porte vitrée ------------------------		
		if porte_vitree then (
			--- montant G ----------
			mgr_constr.ajouter_boite 	mesh		long:		porte_menuis_montants		\
															prof:		porte_profondeur		\
															ht:		( hauteur_reel - menuis_epaisseur )			\
															transf:	(transMatrix [ ecart_cote , 0 ,0 ] * matrx_origine_ouvrant	*	matrix_ouverture )	\
															matID:	matId_menuis
								
			--- montant D ----------
			mgr_constr.ajouter_boite 	mesh		long:		porte_menuis_montants		\
															prof:		porte_profondeur		\
															ht:		( hauteur_reel - menuis_epaisseur )			\
															transf:	( transMatrix [ -ecart_cote , 0 ,0 ] * matrx_origine_ouvrant * transMatrix  [long_trav - porte_menuis_montants,0,0]	*	matrix_ouverture )	\
															matID:	matId_menuis
			
			--- traverse Basse ----------
			mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 *porte_menuis_montants - 2* ecart_cote)		\
															prof:		porte_profondeur		\
															ht:		porte_menuis_travBasse			\
															transf:	( transMatrix [ ecart_cote , 0 ,0 ] * matrx_origine_ouvrant * transMatrix  [porte_menuis_montants,0,0]	*	matrix_ouverture )	\
															matID:	matId_menuis
			
			--- traverse ht ----------
			mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 *porte_menuis_montants - 2* ecart_cote)			\
															prof:		porte_profondeur		\
															ht:		porte_menuis_montants			\
															transf:	(transMatrix [ ecart_cote , 0 , -ecart_bas - ecart_cote ] *  matrx_origine_ouvrant * transMatrix  [porte_menuis_montants,0,hauteur -  menuis_epaisseur - porte_menuis_montants]	*	matrix_ouverture )	\
															matID:	matId_menuis
			
			--- vitrage ----------
			mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 *porte_menuis_montants - 2* ecart_cote)		\
															prof:		vitrage_ep		\
															ht:		( hauteur_reel - ( porte_menuis_travBasse + porte_menuis_montants + menuis_epaisseur  ) )			\
															transf:	( transMatrix [ ecart_cote , 0 ,0 ] * matrx_origine_ouvrant * transMatrix  [porte_menuis_montants, (porte_profondeur - vitrage_ep) / 2  , porte_menuis_travBasse]	*	matrix_ouverture )	\
															matID:	matId_vitrage
		) else (
			--- porte pleine ----------
			mgr_constr.ajouter_boite 	mesh		long:		( long_trav - 2 * ecart_cote )		\
															prof:		porte_profondeur	\
															ht:		( hauteur_reel - menuis_epaisseur)			\
															transf:	( transMatrix [ ecart_cote , 0 ,0 ] * matrx_origine_ouvrant  * matrix_ouverture   )	\
															matID:	matId_menuis
		)
		
		
		
		
		--- les poignées ----------
		if poignees then (
			
			
			
			local poignee_A_decall	=	if not ouverture_inverse then ( long_trav - 7 )	else 3
			local poignee_A_invers	= ouverture_inverse
			local poignee_B_decall	=	if not ouverture_inverse then ( long_trav - 3 )	else 7
			local poignee_B_invers	=	not ouverture_inverse

			---- poignée A -----
			local nvl_poignee 		= createInstance  urba_menuis_poignee	inverser_sens_ouverture:poignee_A_invers		matID:	matId_poignee
			local poignee_mesh 		= copy nvl_poignee.mesh			
			mgr_constr.transform_vertex	poignee_mesh		transf:		( matrx_origine_ouvrant * transMatrix  [poignee_A_decall  ,porte_profondeur, poignee_ht ]	*	matrix_ouverture )	
			meshop.attach		mesh		poignee_mesh
			
			---- poignée B -----
			local nvl_poignee 		= createInstance  urba_menuis_poignee 	inverser_sens_ouverture:poignee_B_invers		matID:	matId_poignee
			local poignee_mesh 		= copy nvl_poignee.mesh			
			mgr_constr.transform_vertex	poignee_mesh		transf:	( rotateZMatrix 180 * matrx_origine_ouvrant * transMatrix  [poignee_B_decall  ,0, poignee_ht ]	*	matrix_ouverture )
			meshop.attach		mesh		poignee_mesh
																
		)
		
		
	) --- fin build mesh ------------------
	
	
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		local affiche_poignee_back
		local affiche_gonds_back
		local affiche_epaisseur_back
		
		
		on mousePoint click do
			case click of
			(
				1: (	
					--- on cache des trucs pendant la creation -----
					affiche_poignee_back 	= poignees
					affiche_gonds_back 		= gonds
					affiche_epaisseur_back = menuis_epaisseur
					poignees 	= false	
					gonds 		= false	
					menuis_epaisseur 	= 0
					
					pt_debut 	=  gridPoint
					nodeTM.translation = pt_debut
				)
				4: (
					--- on reaffiche les trucs apres la creation -----
					poignees 	= affiche_poignee_back
					gonds	 	= affiche_gonds_back
					menuis_epaisseur 	= affiche_epaisseur_back
					
					#stop
				)
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_profondeur	=	gridPoint
				)
				3:	(
					profondeur 				= length ( gridPoint - pt_profondeur )
					pt_hauteur				=	gridPoint
				)
				4:	hauteur 					= length ( gridPoint - pt_hauteur )
			)
		
	)
)

