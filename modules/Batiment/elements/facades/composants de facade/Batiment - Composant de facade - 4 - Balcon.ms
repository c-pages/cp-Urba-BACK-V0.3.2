


	
( ----	FileIn ----
	
	


--- parametres de base	-----------------------------
compo_nom 	= "Balcon"	
compo_type	=	#balcon
compo_toolTip =	""


--- les parametres du composant	---------
struct compo_params	(
	longueur 		= 0,
	largeur			= 100,
	profondeur	= 100,
	gardeCorps	= undefined
)


--- les rollout du composant	---------
rollout compo_dialog "Balcon" width:180 height:120
(
	
	local m_compo
	local m_rollPrt
	local m_plug

	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:73 align:#left
	label 'lbl_largeur' "Balcon:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_balcon_largeur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	label 'lbl_profondeur' "Loggia" pos:[13,51] width:49 height:13 align:#left
	spinner 'spn_loggia_profondeur' "" pos:[96,51] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	
	dropdownList 'ddl_gardeCorps' "" pos:[15,70] width:149 height:21 align:#left
	
	
	fn actualiser =(
		spn_balcon_largeur.value 	= 	m_compo.params.largeur
		edt_nom.text 		=	m_compo.nom
		spn_loggia_profondeur.value 	= 	m_compo.params.profondeur
		
		
		local liste_nomsGardesCorps	=	#("aucun")
		liste_nomsGardesCorps +=	m_plug.core.get_gardeCorps_constructeursNoms ()
		ddl_gardeCorps.items 			= liste_nomsGardesCorps
		
		local gardeCorps_listeTypes	=	m_plug.core.get_gardeCorps_constructeursTypes ()		
		if m_compo.params.gardeCorps != undefined then (			
			local indexSelect_gardeCorps	=	findItem	gardeCorps_listeTypes		m_compo.params.gardeCorps.type			
			ddl_gardeCorps.selection = indexSelect_gardeCorps + 1
		) else ddl_gardeCorps.selection = 1
	)

	
	
	
	
	
	on edt_nom entered txt 	do
	(
			m_compo.nom = txt
			m_rollPrt.actualiser ()
		)
	on spn_balcon_largeur changed val do
		m_compo.params.largeur = val
	on 	spn_loggia_profondeur changed val do
		m_compo.params.profondeur = val
	on ddl_gardeCorps selected _val do
	(
			format "GARDE CORPS selected %\n" _val
			if _val > 1 then (
				local nv_gardeCorps = m_plug.core.creer_gardeCorps		( _val - 1 )
				m_compo.params.gardeCorps = nv_gardeCorps 
				format "nv_gardeCorps: %\n" nv_gardeCorps
			format "-------> m_compo.params.gardeCorps.type %\n" m_compo.params.gardeCorps.type
			) else  m_compo.params.gardeCorps = undefined
		)
)
--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		norm_dir:		 this:		onConstruitLaDalle:false	 onConstruit_gardeCorps:	= (

	
-------------  POINTEURS 			-----------------------------------------------------------------------------------------------------------------
		local ptr_plug				= 	_plug
		local ptr_composant  	= 	this
		local ptr_geo 				= 	ptr_plug.core.get_geo ()
		
-------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
		--- Result -------------
		local pt_result_1, pt_result_2, pt_result_3
		
		--- Vecteurs ------------
		local vec_ep_dalle 	= [0,0,1] 		* 	ep_dalle
		local vec_ht 				= [0,0,1] 		* 	ht_niveaux
		local vec_longueur 	= norm_dir 	* 	longueur
		local vec_prof			= ( norm_dir * rotateZ ( matrix3 1 ) 90 ) *  this.params.profondeur 
		
		--- Points d'accroche ------------
		local id_ptAccroche_1 	= pts_accroches[1]
		local id_ptAccroche_2 	= pts_accroches[2]
		local id_ptAccroche_3 	= pts_accroches[3] 
		
		local ptAccroche_1		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_1	) 
		local ptAccroche_2		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_2	) 
		local ptAccroche_3		=	( polyop.getVert 	ptr_plug.delegate		id_ptAccroche_3	) 
		
		local ep_dalle 			= ptr_plug.const_dalle_epaisseur
		local ht_niveaux 		= distance ptAccroche_2 	ptAccroche_3
		local longueur 			= ptr_composant.params.longueur
		
		
-------------  CONSTRUCTION 	-----------------------------------------------------------------------------------------------------------------
		---- LA DALLE  -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_2 		= ptAccroche_1		+ vec_prof
		local pt_3 		= pt_2					+	vec_ep_dalle 
		
		--- creation des points --------------
		local pts_pos 	= #( pt_2, pt_3 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
-- 		if onConstruitLaDalle do (
			local nvlFace = ptr_geo.face 		#( id_ptAccroche_1, 		pts_ids[1], 		pts_ids[2], 		id_ptAccroche_2 )		
			ptr_geo.set_matID 	nvlFace	#mur 	
-- 		)
		
		--- Result -------------
		pt_result_1 = pts_ids[1]
		pt_result_2 = pts_ids[2]
		
		
		
		---- LE MUR -----------------------------------------------------------------------			
		-------	Creation des points 	--------
		local pt_3 		= pt_3 +	vec_ht 
		
		--- creation des points --------------
		local pts_pos 	= #( pt_3 )
		local pts_ids 	= ptr_geo.points 	pts_pos		
		
		-------	Creation des faces 	--------
		local nvlFace = ptr_geo.face 		#( id_ptAccroche_2, 		pt_result_2, 		pts_ids[1], 		id_ptAccroche_3 )		 
		ptr_geo.set_matID 	nvlFace		#mur 	
		
		--- Result -------------
		pt_result_3 = pts_ids[1]
		
		
		---- Result final -----------------------------------------------------------------------
		#( pt_result_1, pt_result_2, pt_result_3 )
		
		
)
	



------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	